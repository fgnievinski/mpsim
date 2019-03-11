function cs = polyhess2_aux (c)
    cs.c = c;
    cs.cdx  = polyder2x (cs.c);
    cs.cdx2 = polyder2x (cs.cdx);
    cs.cdy  = polyder2y (cs.c);
    cs.cdy2 = polyder2y (cs.cdy);
    cs.cdxy = polyder2y (cs.cdx);
end

