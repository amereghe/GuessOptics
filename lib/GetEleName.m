function eleName=GetEleName(temp)
    % example: temp="I:m1_016a_qib[A]";
    eleName=split(temp,":"); eleName=split(eleName(2),"["); eleName=eleName(1);
end
