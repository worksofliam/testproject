**Free

Dcl-F Product;
Dcl-F Report1 Printer;

Write Header;

Read Product; // Priming read for loop

DoU %Eof(Product);
    Value = STOH * SELLPR;
    Write Detail;
    Read Product;
EndDo;

*InLR= *On;
