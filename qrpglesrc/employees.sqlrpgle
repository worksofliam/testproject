**free
Ctl-Opt DFTACTGRP(*no);

Dcl-Pi EMPLOYEES;
    DEPTNO Char(3);
End-Pi;

Dcl-c SQLSUCCESS '00000';

// ---------------------------------------------------------------*

/INCLUDE qrpgleref,constants

// ---------------------------------------------------------------*

Dcl-F emps WORKSTN Sfile(SFLDta:Rrn) IndDS(WkStnInd) InfDS(fileinfo);

Dcl-S Exit Ind Inz(*Off);
// Hello world

Dcl-S Rrn          Zoned(4:0) Inz;
// Hello world

Dcl-DS WkStnInd;
    ProcessSCF     Ind        Pos(21);
    ReprintScf     Ind        Pos(22);
    Error          Ind        Pos(25);
    PageDown       Ind        Pos(30);
    PageUp         Ind        Pos(31);
    SflEnd         Ind        Pos(40);
    SflBegin       Ind        Pos(41);
    NoRecord       Ind        Pos(60);
    SflDspCtl      Ind        Pos(85);
    SflClr         Ind        Pos(75);
    SflDsp         Ind        Pos(95);
End-DS; //New comment

Dcl-DS FILEINFO;
    FUNKEY         Char(1)    Pos(369);
End-DS;

// ---------------------------------------------------------------*

Dcl-S Index Int(5);

Dcl-Ds EmployeeDs ExtName('EMPLOYEE') Alias Qualified;
End-Ds;

// ------------------------------------------------------------reb04
Exit = *Off;
LoadSubfile();

Dow (Not Exit);
    Write FOOTER_FMT;
    Exfmt SFLCTL;
    //Hello world

    Select;
        When (Funkey = F12);
            Exit = *On;
        When (Funkey = ENTER);
            HandleInputs();
    Endsl;
Enddo;

*INLR = *ON;
Return;

// ------------------------------------------------------------

Dcl-Proc ClearSubfile;
    SflDspCtl = *Off;
    SflDsp = *Off;

    Write SFLCTL;

    SflDspCtl = *On;

    Rrn = 0;
End-Proc;

Dcl-Proc LoadSubfile;
    Dcl-S lCount  Int(5);
    Dcl-S Action  Char(1);
    Dcl-S LongAct Char(3);
    Dcl-s DeptNum Char(3);

    ClearSubfile();

    EXEC SQL DECLARE empCur CURSOR FOR
              SELECT EMPNO, FIRSTNME, LASTNAME, JOB
              FROM Employee
              WHERE WORKDEPT = DeptNum;

    EXEC SQL OPEN empCur;

    // Some comment
    if (sqlstate = SQLSUCCESS);

        dou (sqlstate <> SQLSUCCESS);
            EXEC SQL
                  FETCH NEXT FROM empCur
                  INTO :EmployeeDs.EMPNO,
                       :EmployeeDs.FIRSTNME,
                       :EmployeeDs.LASTNAME,
                       :EmployeeDs.JOB;

            if (sqlstate = SQLSUCCESS);
                XID   = EmployeeDs.EMPNO;
                XNAME = %TrimR(EmployeeDs.LASTNAME) + ', '
                      + %TrimR(EmployeeDs.FIRSTNME);
                XJOB  = EmployeeDs.JOB;

                Rrn += 1;
                Write SFLDTA;
            endif;
        enddo;

    endif;

    EXEC SQL CLOSE empCur;

    If (Rrn > 0);
        SflDsp = *On;
        SFLRRN = 1;
    Endif;
End-Proc;

Dcl-Proc HandleInputs;
    Dcl-S SelVal Char(1);

    Dou (%EOF(emps));
        ReadC SFLDTA;
        If (%EOF(emps));
            Iter;
        Endif;

        SelVal = %Trim(XSEL);

        Select;
            When (SelVal = '5');
                DSPLY XID;
        Endsl;

        If (XSEL <> *Blank);
            XSEL = *Blank;
            Update SFLDTA;
            SFLRRN = Rrn;
        Endif;
    Enddo;

    resetrrn();
End-Proc;

Dcl-Proc resetrrn;
    Rrn = 0;
End-Proc;
