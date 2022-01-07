function eleNames=GetEleName(temp)
    % example: temp="I:m1_016a_qib[A]";
    tmpEleNames=split(temp,":");
    if ( length(temp)==1 ), tmpEleNames=tmpEleNames'; end % single name in temp
    tmpEleNames=split(tmpEleNames(:,2),"[");
    if ( length(temp)==1 ), tmpEleNames=tmpEleNames'; end % single name in temp
    eleNames=tmpEleNames(:,1);
end
