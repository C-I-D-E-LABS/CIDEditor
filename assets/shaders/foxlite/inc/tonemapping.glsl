// HDRtoLDR and LDRtoHDR from https://www.shadertoy.com/view/ltVBWc

const float whiteSoftness = 0.15;

vec3 HDRtoLDR( vec3 col )
{
    // soft clamp to white (oh this is so good)
    float w2 = whiteSoftness*whiteSoftness;
    col += w2;
    col = (1.0-col)*.5;
    col = 1.0 - (sqrt(col*col+w2) + col);
    
    // linear to sRGB (approx)
    col = pow( col, vec3(1.0/2.2) );

    return col;
}

vec3 LDRtoHDR( vec3 col )
{
    // sRGB to linear (approx)
    col = pow( col, vec3(2.2) );
    
    col = clamp(col,0.0,.99);
    
    float w2 = whiteSoftness*whiteSoftness;
    col = (w2 - col*col + 2.0*col - 1.0)/(2.0*(col - 1.0)); // inverted by wolfram
    col = 1.0-col*2.0;
    col -= w2;
    
    return col;
}

vec3 TekF_Tonemap(vec3 color) {
    color = LDRtoHDR(color);
    color *= 2.2;
    return HDRtoLDR(color);
}