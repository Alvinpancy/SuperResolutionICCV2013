function rgb = YIQ2RGB( yiq )
    T = [0.299,0.587,0.114;0.595716,-0.274453,-0.321263;0.211456,-0.522591,0.311135];
    invT = inv(T);
    rgb(:,:,1) = invT(1,1) * yiq(:,:,1) + invT(1,2) * yiq(:,:,2) + invT(1,3) * yiq(:,:,3);
    rgb(:,:,2) = invT(2,1) * yiq(:,:,1) + invT(2,2) * yiq(:,:,2) + invT(2,3) * yiq(:,:,3);
    rgb(:,:,3) = invT(3,1) * yiq(:,:,1) + invT(3,2) * yiq(:,:,2) + invT(3,3) * yiq(:,:,3);
end