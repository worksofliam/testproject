**free
ctl-opt dftactgrp(*NO);

dcl-pi sum;
    num1 packed(15:5);
    num2 packed(15:5);
end-pi;

dcl-s nums int(10) dim(2);
dcl-s totalValue int(10);
nums(1) = num1;
nums(2) = num2;

totalValue = doSum(nums);

dsply %char(totalValue);
return;

dcl-proc doSum;
    dcl-pi *n int(10);
        arr int(10) dim(2);
    end-pi;

    dcl-s count int(10) inz(0);
    dcl-s i int(10);
    for i = 1 to %elem(arr);
        count += arr(i);
    endfor;
    return count;
end-proc;
