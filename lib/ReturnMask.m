function myMask=ReturnMask(iSet,tmpX)
    switch iSet
        case 11
            myMask=true(size(tmpX));
            myMask(:,1)=~((16  <=tmpX(:,1) & tmpX(:,1)<=18 ) | (tmpX(:,1)==-10.87));
            myMask(:,2)=~((-20.00<=tmpX(:,2) & tmpX(:,2)<=-15.00 ) | (9.00<=tmpX(:,2) & tmpX(:,2)<=14.00 ));
        case 12
            myMask=true(size(tmpX));
            myMask(:,1)=~(tmpX(:,1)==-31.73);
            myMask(:,2)=~((-1.00<=tmpX(:,2) & tmpX(:,2)<=3.00 ) | (tmpX(:,2)==-31.42) | (tmpX(:,2)==30.98) );
        case 13
            myMask=true(size(tmpX));
            myMask(:,1)=~(( 4.00<=tmpX(:,2) & tmpX(:,2)<= 8.00 ) );
            myMask(:,2)=~((-6.00<=tmpX(:,2) & tmpX(:,2)<=-2.00 ) );
        case 15
            myMask=true(size(tmpX));
            myMask(:,1)=~(tmpX(:,1)==-9.45);
            myMask(:,2)=~((-13.00<=tmpX(:,2) & tmpX(:,2)<=-11.00 ) | (tmpX(:,2)==-8.45) );
        otherwise
            % checked 14
            myMask=missing();
    end
end
