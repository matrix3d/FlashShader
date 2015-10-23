FrameItem = function( bin ) {
	this.type = bin.readUint8();
	if ( this.type === 0 ) {
		this.index = bin.readBoneIndex();
	} else
	if ( this.type === 1 ) {
		this.index = bin.readMorphIndex();
	} else {
		throw Exception.DATA;
	}
};

Frame = function( bin ) {
	var n;
	this.name = bin.readText();
	this.nameEn = bin.readText();
	this.special = bin.readUint8();
	this.items = [];
	n = bin.readInt32();
	while (n-- > 0) {
		this.items.push( new FrameItem( bin ) );
	}
};




MMDSkin.prototype.onupdate = function( currKey, nextKey, ratio, idx ) {
	var bone = this.mesh.bones[ idx ],
		gbone = this.mesh.geometry.bones[ idx ],
		interp;
	//if (nextKey.interp) { // curr ではなく next 側を参照のこと。
		interp = nextKey.interp;
		// cubic bezier
		bone.position.x = gbone.pos[0] + currKey.pos[0] + ( nextKey.pos[0] - currKey.pos[0] ) * bezierp( ratio, interp, 0 );
		bone.position.y = gbone.pos[1] + currKey.pos[1] + ( nextKey.pos[1] - currKey.pos[1] ) * bezierp( ratio, interp, 1 );
		bone.position.z = gbone.pos[2] + currKey.pos[2] + ( nextKey.pos[2] - currKey.pos[2] ) * bezierp( ratio, interp, 2 );
		slerp( currKey.rot, nextKey.rot, _q, bezierp( ratio, interp, 3) );
		bone.quaternion.x = _q[0];
		bone.quaternion.y = _q[1];
		bone.quaternion.z = _q[2];
		bone.quaternion.w = _q[3];
};

}()); // MMDSkin

// additional transform
MMDAddTrans = function( pmx, mesh ) {
	var bones;
	this.mesh = mesh;
	bones = []; // 対象ボーン
	mesh.bones.forEach( function( v, i ) {
		var at, ref;
		v.pmxBone = pmx.bones[i]; // meshのboneからpmxのboneを参照できるようにする。
		at = v.pmxBone.additionalTransform;
		if ( at && at[0] >= 0 && at[1] !== 0 ) {
			// 付与で参照されるボーンには、変形量の差分を求めるためのプロパティを追加。
			ref = mesh.bones[ at[0] ];
			ref.basePosition = ref.position.clone();
			ref.baseQuaternion = ref.quaternion.clone();
			ref.baseSkinMatrix = ref.skinMatrix.clone();
			/* とりあえず考慮しない。
			if ( ( v.pmxBone.flags & 0x1000 ) !== 0 ) {
				// 物理演算後変形。
				return;
			} */
			bones.push( v );
		}
	});
	bones.sort( function( a, b ) {
		// 変形階層で昇順にソート。
		return a.pmxBone.deformHierachy - b.pmxBone.deformHierachy;
	});
	this.hasGlobal = bones.some( function( v ) { 
		// boneローカルな変形量ではなく、グローバルなskinMatrixを参照するかどうか。
		return ( (v.pmxBone.flags & 0x80) !== 0 );
	});
	this.bones = bones;
};
MMDAddTrans.prototype.update = function() {
	var mesh;
	mesh = this.mesh;
	if ( this.hasGlobal ) {
		mesh.updateMatrixWorld(); // bone の skinMatrix を更新させる。
	}
	this.bones.forEach( function( v ) {
		var at, ref, weight;
		at = v.pmxBone.additionalTransform;
		ref = mesh.bones[ at[0] ];
		// get delta transform
		// deltaPosition = position - basePosition
		// deltaQuaternion = quaternion - baseQuaternion
		if ( (v.pmxBone.flags & 0x80 ) !== 0 ) {
			// 未検証。
			_v.getPositionFromMatrix( ref.skinMatrix );
			_v2.getPositionFromMatrix( ref.baseSkinMatrix );
			dv.subVectors( _v, _v2 );
			_q.setFromRotationMatrix( ref.skinMatrix );
			_q2.setFromRotationMatrix( ref.baseSkinMatrix );
			dq.multiplyQuaternions( _q2.conjugate() , _q );
		} else {
			dv.subVectors( ref.position, ref.basePosition );
			//dq.multiplyQuaternions( _q.copy( ref.baseQuaternion ).conjugate() , ref.quaternion );
			dq.copy( ref.quaternion ); // 実際には baseQuaternion = (0,0,0,1) なので簡略。
		}
		weight = at[1];
		if ( ( v.pmxBone.flags & 0x100) !== 0 ) {
			// 回転付与。
			_q.set(0,0,0,1);
			if ( weight >= 0) {
				// 順回転。
				_q.slerp( dq, weight );
			} else {
				// 逆回転。
				_q.slerp( dq.conjugate(), -weight );
			}
			v.quaternion.multiplyQuaternions( v.quaternion, _q );
		}
		if ( ( v.pmxBone.flags & 0x200) !== 0 ) {
			// 移動付与。
			v.position.addVectors( v.position, dv.multiplyScalar(weight) );
		}
	});
};

}()); // MMDAddTrans


Model.prototype.create = function( param, oncreate ) {
	var that;
	that = this;
	if ( this.pmx ) {
		this.pmx.createMesh( param, function( mesh ) {
			var animation;
			that.mesh = mesh;
			mesh.identityMatrix = null; // 少し速くなるかも。
			mesh.useQuaternion = true;
			if ( param.position ) {
				mesh.position.copy( param.position );
			}
			if ( param.rotation ) {
				mesh.rotation.copy( param.rotation );
				mesh.useQuaternion = false;
			}
			if ( param.quaternion ) {
				mesh.quaternion.copy( param.quaternion );
				mesh.useQuaternion = true;
			}
			that.boundingCenterOffset = mesh.geometry.boundingSphere.center.clone().sub( mesh.bones[0].position ); // offset from skeleton center
			if ( mesh.geometry.MMDIKs.length ) {
				that.ik = new MMDIK( mesh );
			} else {
				that.ik = null;
			}
			if ( window.Ammo && mesh.geometry.MMDrigids.length ) {//mod by jThree
				that.physi = new MMDPhysi( mesh );
			} else {
				that.physi = null;
			}
			if ( that.vmd ) {
				animation = that.vmd.generateSkinAnimation( that.pmx );
				if ( animation ) {
					that.skin = new MMDSkin( mesh, animation );
					that.skin.onended = function( skin ) {
						if ( skin.loop ) {
							if ( that.physi ) {
								that.physi.reset();
							}
						}
						that._onmotionended = that.onmotionended; // mark
					};
					if ( that.physi ) {
						// 物理演算をやる場合は、
						// boneMatrices の更新は自前でやるので updateMatrixWorld を override する。
						// override しなくても動作するが、無駄な計算を減らすため。
						mesh.updateMatrixWorld = skinnedMesh_updateMatrixWorld;
					}
				} else {
					that.skin = null;
				}
				animation = that.vmd.generateMorphAnimation( that.pmx );
				if ( animation  ) {
					that.morph = new MMDMorph( mesh, animation );
				} else {
					that.morph = null;
				}
			}
			if ( hasAdditionalTransform( that.pmx ) ) {
				that.addTrans = new MMDAddTrans( that.pmx, mesh );
			} else {
				that.addTrans = null;
			}
			oncreate( that );
		});
	}
};
Model.prototype.updateMotion = function( dt, force ) {
	this.resetBones();
	if ( this.morph ) {
		this.morph.update( dt, force );
	}
	if ( this.skin ) {
		this.skin.update( dt, force );
		this.mesh.geometry.boundingSphere.center.addVectors( this.mesh.bones[0].position, this.boundingCenterOffset );
	}
	if ( this.ik ) {
		this.ik.update();
	}
	if ( this.addTrans ) {
		this.addTrans.update();
	}
	this.checkCallback();
};
Model.prototype.seekMotion = function( time, forceUpdate ) {
	if ( this.ik ) {
		this.ik.update();
	}
	if ( this.addTrans ) {
		this.addTrans.update();
	}
};