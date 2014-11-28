/*
 * wad.js
 * 
 * Copyright (c) 2012, Bernhard Manfred Gruber. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

'use strict';

/*
typedef struct
{
    char    szMagic[4]; 
    int32_t nDir;       
    int32_t nDirOffset;
} WADHEADER;
*/
function WadHeader()
{
    var magic;     // should be WAD2/WAD3
    var dirs;      // number of directory entries
    var dirOffset; // offset into directory
}
var SIZE_OF_WADHEADER = 12;

// Directory entry structure
/*
typedef struct _WADDIRENTRY
{
    int32_t nFilePos;            
    int32_t nDiskSize;             
    int32_t nSize;                 
    int8_t  nType;                 
    bool    bCompression;  
    int16_t nDummy;             
    char    szName[MAXTEXTURENAME];
} WADDIRENTRY;
*/

function WadDirEntry()
{
    var offset;           // offset in WAD
    var compressedSize;   // size in file
    var size;             // uncompressed size
    var type;             // type of entry
    var compressed;       // 0 if none
    var name;             // must be null terminated
}

/**
 * Wad class.
 * Represents a wad archiev and offers methods for extracting textures from it.
 */
function Wad()
{
	/** Identifies the wad */
	var name;

	var src;
	
	/** Wad file header */
	var header;
	
	/** Array of directory entries */
	var entries;
};

/**
 * Opens the wad file and loads it's directory for texture searching.
 */
Wad.prototype.open = function(buffer)
{
	console.log('Begin loading wad');

	this.src = new BinaryFile(buffer);

	var src = this.src;
	
	var header = new WadHeader();
	header.magic = src.readString(4);
	header.dirs = src.readLong();
	header.dirOffset = src.readLong();
	
	console.log('Header: ' + header.magic + ' (' + header.dirs + ' contained objects)');
	
	if(header.magic != 'WAD2' && header.magic != 'WAD3')
		return false;
	
	this.header = header;
	this.entries = new Array();
	
	src.seek(header.dirOffset);
	
	for(var i = 0; i < header.dirs; i++)
	{
		var entry = new WadDirEntry();
		
		entry.offset = src.readLong();
		entry.compressedSize = src.readLong();
		entry.size = src.readLong();
		entry.type = src.readByte();
		entry.compressed = (src.readUByte() ? true : false);
		src.readUShort();
		entry.name = src.readString(MAXTEXTURENAME);
		
		console.log('Texture #' + i + ' name: ' + entry.name);
		
		this.entries.push(entry);
	}
	
	console.log('Finished loading wad');
	
	return true;
}

/**
 * Finds and loads a texture from the wad file.
 *
 * @param texName The name of the texture to find.
 * @return Returns the OpenGL identifier for the loaded textrue obtained by calling gl.createTexture()
 *         or null if the texture could not be found.
 */
Wad.prototype.loadTexture = function(texName)
{
	// Find cooresponding directory entry
	for(var i = 0; i < this.entries.length; i++)
	{
		var entry = this.entries[i];
		if(entry.name.toLowerCase() == texName.toLowerCase())
			return this.fetchTextureAtOffset(this.src, entry.offset);
	}
	
	return null;
}

/**
 * Static method for fetching a texture at a given offset from a byte buffer.
 * Reads the texture header and decodes the indexed image into a rgba image.
 * Finally creates a OpenGL texture.
 *
 * @param src A BinaryFile object used to read data from.
 * @param offset The offset in the binary file to start reading.
 * @return Returns a WebGLTexture obtained by calling createTexture().
 */
Wad.prototype.fetchTextureAtOffset = function(src, offset)
{
	// Seek to the texture beginning
	src.seek(offset);
	
	// Load texture header
	var mipTex = new BspMipTexture();
	mipTex.name = src.readString(MAXTEXTURENAME);
	mipTex.width = src.readULong();
	mipTex.height = src.readULong();
	mipTex.offsets = new Array();
	for(var i = 0; i < MIPLEVELS; i++)
		mipTex.offsets.push(src.readULong());

	// Fetch color palette
	var paletteOffset = mipTex.offsets[MIPLEVELS - 1] + ((mipTex.width / 8) * (mipTex.height / 8)) + 2;
	
	var palette = new Uint8Array(src.buffer, offset + paletteOffset, 256 * 3);

	// Generate texture
	//var texture = gl.createTexture();
	//gl.bindTexture(gl.TEXTURE_2D, texture);

    //for (var i = 0; i < MIPLEVELS; i++) // ONLY LOAD FIRST MIPLEVEL !!!
    {   
		// Width and height shrink to half for every level
		var width = mipTex.width; //>> i;
		var height = mipTex.height; // >> i;
		
		// Fetch the indexed texture
		var textureIndexes = new Uint8Array(src.buffer, offset + mipTex.offsets[0 /*i*/], width * height);
		
		// Allocate storage for the rgba texture
		var textureData = new Array(width * height * 4);

		// Translate the texture from indexes to rgba
        for (var j = 0; j < width * height; j++)
        {
                var paletteIndex = textureIndexes[j] * 3;

                textureData[j * 4]     = palette[paletteIndex];
                textureData[j * 4 + 1] = palette[paletteIndex + 1];
                textureData[j * 4 + 2] = palette[paletteIndex + 2];
                textureData[j * 4 + 3] = 255; //every pixel is totally opaque
        }

		if(mipTex.name.substring(0, 1) == "{") // this is an alpha texture
		{
			console.log(mipTex.name + " is an alpha texture");
			// Transfere alpha key color to actual alpha values
			this.applyAlphaSections(textureData, width, height, palette[255 * 3 + 0], palette[255 * 3 + 1], palette[255 * 3 + 2]);
		}
		
		// Upload the data to OpenGL
		//var img = pixelsToImage(textureData, width, height, 4);
		
		//$('body').append('<span>Texture (' + img.width + 'x' + img.height + ')</span>').append(img);
		
		//gl.texImage2D(gl.TEXTURE_2D, 0 /*i*/, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
    }
	
	var texture = pixelsToTexture(textureData, width, height, 4, function(texture, image)
	{
		gl.bindTexture(gl.TEXTURE_2D, texture);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR_MIPMAP_LINEAR);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
		gl.texImage2D(gl.TEXTURE_2D, 0 , gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
		gl.generateMipmap(gl.TEXTURE_2D);
		gl.bindTexture(gl.TEXTURE_2D, null);
	});
	

	
	return texture;
}

/**
 * Translates the transparent regions of an image given by a selected "transparency color"
 * into actual alpha values.
 * Also performs color interpolation at the edges of transparent regions to prevent that the
 * "transparency color" can be seen on the final texture.
 *
 * @param pixels An array of pixels (rgba) which will be altered.
 * @param width The width of the image hold by pixels.
 * @param height The height of the image hold by pixels.
 * @param key* The "transparency color".
 */
Wad.prototype.applyAlphaSections = function(pixels, width, height, keyR, keyG, keyB)
{
	// Create an equally sized pixel buffer initialized to the key color 
	var rgbBuffer = new Array(width * height * 3);
	
	for(var y = 0; y < height; y++)
	{
		for(var x = 0; x < width; x++)
		{
			var bufIndex = (y * width + x) * 3;
			rgbBuffer[bufIndex + 0] = keyR;
			rgbBuffer[bufIndex + 1] = keyG;
			rgbBuffer[bufIndex + 2] = keyB;
		}
	}

	// The key color signifies a transparent portion of the texture. Zero alpha for blending and
	// to get rid of key colored edges choose the average color of the nearest non key pixels.
	
	// Interpolate colors for transparent pixels
	for(var y = 0; y < height; y++)
	{
		for(var x = 0; x < width; x++)
		{
            var index = (y * width + x) * 4;

            if ((pixels[index + 0] == keyR) &&
				(pixels[index + 1] == keyG) &&
				(pixels[index + 2] == keyB))
            {
				// This is a pixel which should be transparent
				
				pixels[index + 3] = 0;

                var count = 0;
                var colorSum = new Array(3);
				colorSum[0] = 0;
				colorSum[1] = 0;
				colorSum[2] = 0;

                // left above pixel
                if((x > 0) && (y > 0))
                {
                    var pixelIndex = ((y - 1) * width + (x - 1)) * 4;
                    if (pixels[pixelIndex + 0] != keyR ||
						pixels[pixelIndex + 1] != keyG ||
						pixels[pixelIndex + 2] != keyB)
                    {
                        colorSum[0] += pixels[pixelIndex + 0] * Math.SQRT2;
                        colorSum[1] += pixels[pixelIndex + 1] * Math.SQRT2;
                        colorSum[2] += pixels[pixelIndex + 2] * Math.SQRT2;
                        count++;
                    }
                }

                // above pixel
                if((x >= 0) && (y > 0))
                {
                    var pixelIndex = ((y - 1) * width + x) * 4;
                    if (pixels[pixelIndex + 0] != keyR ||
						pixels[pixelIndex + 1] != keyG ||
						pixels[pixelIndex + 2] != keyB)
                    {
                        colorSum[0] += pixels[pixelIndex + 0];
                        colorSum[1] += pixels[pixelIndex + 1];
                        colorSum[2] += pixels[pixelIndex + 2];
                        count++;
                    }
                }

                // right above pixel
                if((x < width - 1) && (y > 0))
                {
                    var pixelIndex = ((y - 1) * width + (x + 1)) * 4;
                    if (pixels[pixelIndex + 0] != keyR ||
						pixels[pixelIndex + 1] != keyG ||
						pixels[pixelIndex + 2] != keyB)
                    {
                        colorSum[0] += pixels[pixelIndex + 0] * Math.SQRT2;
                        colorSum[1] += pixels[pixelIndex + 1] * Math.SQRT2;
                        colorSum[2] += pixels[pixelIndex + 2] * Math.SQRT2;
                        count++;
                    }
                }

                // left pixel
                if(x > 0)
                {
                    var pixelIndex = (y * width + (x - 1)) * 4;
                    if (pixels[pixelIndex + 0] != keyR ||
						pixels[pixelIndex + 1] != keyG ||
						pixels[pixelIndex + 2] != keyB)
                    {
                        colorSum[0] += pixels[pixelIndex + 0];
                        colorSum[1] += pixels[pixelIndex + 1];
                        colorSum[2] += pixels[pixelIndex + 2];
                        count++;
                    }
                }

                // right pixel
                if(x < width - 1)
                {
                    var pixelIndex = (y * width + (x + 1)) * 4;
                    if (pixels[pixelIndex + 0] != keyR ||
						pixels[pixelIndex + 1] != keyG ||
						pixels[pixelIndex + 2] != keyB)
                    {
                        colorSum[0] += pixels[pixelIndex + 0];
                        colorSum[1] += pixels[pixelIndex + 1];
                        colorSum[2] += pixels[pixelIndex + 2];
                        count++;
                    }
                }

                // left underneath pixel
                if((x > 0) && (y < height - 1))
                {
                    var pixelIndex = ((y + 1) * width + (x - 1)) * 4;
                    if (pixels[pixelIndex + 0] != keyR ||
						pixels[pixelIndex + 1] != keyG ||
						pixels[pixelIndex + 2] != keyB)
                    {
                        colorSum[0] += pixels[pixelIndex + 0] * Math.SQRT2;
                        colorSum[1] += pixels[pixelIndex + 1] * Math.SQRT2;
                        colorSum[2] += pixels[pixelIndex + 2] * Math.SQRT2;
                        count++;
                    }
                }

                // underneath pixel
                if((x >= 0) && (y < height - 1))
                {
                    var pixelIndex = ((y + 1) * width + x) * 4;
                    if (pixels[pixelIndex + 0] != keyR ||
						pixels[pixelIndex + 1] != keyG ||
						pixels[pixelIndex + 2] != keyB)
                    {
                        colorSum[0] += pixels[pixelIndex + 0];
                        colorSum[1] += pixels[pixelIndex + 1];
                        colorSum[2] += pixels[pixelIndex + 2];
                        count++;
                    }
                }

                // right underneath pixel
                if((x < width - 1) && (y < height - 1))
                {
                    var pixelIndex = ((y + 1) * width + (x + 1)) * 4;
                    if (pixels[pixelIndex + 0] != keyR ||
						pixels[pixelIndex + 1] != keyG ||
						pixels[pixelIndex + 2] != keyB)
                    {
                        colorSum[0] += pixels[pixelIndex + 0] * Math.SQRT2;
                        colorSum[1] += pixels[pixelIndex + 1] * Math.SQRT2;
                        colorSum[2] += pixels[pixelIndex + 2] * Math.SQRT2;
                        count++;
                    }
                }

                if (count > 0)
                {
                    colorSum[0] /= count;
                    colorSum[1] /= count;
                    colorSum[2] /= count;

					var bufIndex = (y * width + x) * 3;
                    rgbBuffer[bufIndex + 0] = Math.round(colorSum[0]);
                    rgbBuffer[bufIndex + 1] = Math.round(colorSum[1]);
                    rgbBuffer[bufIndex + 2] = Math.round(colorSum[2]);
                }
            }
        }
    }

    // Transfer interpolated colors to the texture
	for(var y = 0; y < height; y++)
	{
		for(var x = 0; x < width; x++)
		{
            var index = (y * width + x) * 4;
			var bufindex = (y * width + x) * 3;

            if ((rgbBuffer[bufindex + 0] != keyR) ||
				(rgbBuffer[bufindex + 1] != keyG) ||
				(rgbBuffer[bufindex + 2] != keyB))
            {
				pixels[index + 0] = rgbBuffer[bufindex + 0];
				pixels[index + 1] = rgbBuffer[bufindex + 1];
				pixels[index + 2] = rgbBuffer[bufindex + 2];
            }
        }
    }
}

/** Stores all loaded wads */
var loadedWads = new Array();