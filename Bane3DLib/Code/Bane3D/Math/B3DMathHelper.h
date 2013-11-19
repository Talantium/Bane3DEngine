//
//  B3DMathHelper.h
//  Bane3D
//
//  Created by Andreas Hanft on 08.04.11.
//
//
//  Copyright (C) 2012 Andreas Hanft (talantium.net)
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#ifndef __B3D_MATH_HELPER_H
#define __B3D_MATH_HELPER_H

#include <cmath>
#include <cstring>
#include <iostream>
#include <cassert>


#ifdef __cplusplus

/**
 * @brief Constrains a value inside an defined interval.
 * @param value Value that should be clamped.
 * @param min Minimum value allowed.
 * @param max Maximum value allowed.
 * @return Either value, min or max depending on actual value.
 */
template <typename TYPE>
inline TYPE clamp(const TYPE& value, const TYPE& min, const TYPE& max)
{
	return std::min(std::max(value, min), max);
}


/**
 * @brief Constrains a value between [0 .. 1].
 * @param value Value that should be clamped.
 * @return Either value, 0 or 1 depending on value.
 */
template <typename TYPE>
inline TYPE clamp01(const TYPE& value)
{
	return std::min(std::max(value, (TYPE)0), (TYPE)1);
}


/**
 * @brief Linear interpolation between two values.
 * @param a Start value to interpolate from.
 * @param b End value to interpolate to.
 * @param alpha Interpolation factor, clamped between [0 .. 1]
 * @return Value between [a .. b] depending on alpha.
 */
template <typename TYPE>
inline TYPE lerp(TYPE a, TYPE b, TYPE alpha)
{
    return clamp01(alpha) * (b - a) + a;
}


/**
 * Converts angles from degree to radians
 */
template <typename TYPE>
inline TYPE deg2rad(const TYPE& value)
{
	return (TYPE)(value / 180.0 * M_PI);
}


/**
 * Converts angles from radians to degree
 */
template <typename TYPE>
inline TYPE rad2deg(const TYPE& value)
{
	return (TYPE)(value / M_PI * 180.0);
}


/**
 * Returns the next value to 'original' that is power of two
 */
inline uint nextPowerOfTwo(uint original)
{
    // Some bitshift magic, found on the internet :)
    original--;
    original |= original >> 1;
	original |= original >> 2;
    original |= original >> 4;
	original |= original >> 8;
    original |= original >> 16;
    original++;
	
    return original;
}

inline float Random01()
{
    return (double)arc4random() / (double)UINT32_MAX;
}
    
#else
#warning This code requires to be compiled as Objective-C++!
#endif

#endif /* __B3D_MATH_HELPER_H */
