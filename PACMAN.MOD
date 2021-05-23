MODULE DisplayFigures;
(**************************************************************************)
(* Modula-2 program to demonstrate the coroutine facility defined by the  *)
(* language Modula-2.                                                     *)
(* By Fritz Feuerbacher                                                   *)
(**************************************************************************)

FROM Schedule  IMPORT Semaphore, MakeReady, Scheduler, Terminate,
                      InitSem, P, V;
FROM Utilities IMPORT CenterStr, PressKey;
FROM ASCII     IMPORT bs;
FROM StdInOut  IMPORT CLS, GotoXY, WriteString, WriteCard;
FROM InOut     IMPORT Write;
FROM Delay     IMPORT Delay;
FROM TimeLib   IMPORT GetMsec;
FROM Video     IMPORT CursorOff, CursorOn;

CONST wkspSize = 1000;
      middleRow = 12;
      numColumns = 60;
      delayTime = 200;

VAR   leftColumn,
      rightColumn,
      LeftMSec,
      RightMSec       : CARDINAL;
      criticalSection : Semaphore;

PROCEDURE MoveLeftFigure;

  BEGIN
    WHILE leftColumn < rightColumn DO
      P(criticalSection);
      GotoXY(26, middleRow-2);
      WriteCard(GetMsec()-LeftMSec, 6);
      LeftMSec := GetMsec();
      GotoXY(leftColumn, middleRow);
      Write("-");
      Delay(100);
      Write(bs);
      Write("<");
      Delay(delayTime);
      Write(bs);
      Write("-");
      Delay(100);
      Write(bs);
      Write(" ");
      INC(leftColumn);
      V(criticalSection);
   END (* while *);
   Terminate;
END MoveLeftFigure;

PROCEDURE MoveRightFigure;

  BEGIN
    WHILE leftColumn < rightColumn DO
      P(criticalSection);
      GotoXY(58, middleRow-2);
      WriteCard(GetMsec()-RightMSec, 6);
      RightMSec := GetMsec();
      GotoXY(rightColumn, middleRow);
      Write("-");
      Delay(100);
      Write(bs);
      Write(">");
      Delay(delayTime);
      Write(bs);
      Write("-");
      Delay(100);
      Write(bs);
      Write(" ");
      DEC(rightColumn);
      V(criticalSection);
   END (* while *);
   Terminate;
END MoveRightFigure;

BEGIN

     CLS;
     CursorOff;
     GotoXY(0,1);
     WriteString("Pre-emptive concurrent programming example using Modula-2 Coroutines.");
     GotoXY(0,3);
     WriteString("Each pac-man is a seperate process which is pre-empted either by blocking itself");
     GotoXY(0,4);
     WriteString("i.e. doing a P on a semaphore, or by the scheduler because it ran out of its");
     GotoXY(0,5);
     WriteString("time quantum.  The scheduler uses the system clock interrupt to gain control!");
     GotoXY(0,6);
     WriteString("A semaphore is used to guard the column integer shared between processes.");

     InitSem(criticalSection, 1);

     leftColumn := 10;
     rightColumn := numColumns;

     MakeReady(MoveLeftFigure, wkspSize);
     MakeReady(MoveRightFigure, wkspSize);

     GotoXY(rightColumn, middleRow);
     FOR LeftMSec := leftColumn TO rightColumn DO
         GotoXY(LeftMSec, middleRow);
         Write("-");
     END (* for *);

     GotoXY(3, middleRow-2);
     WriteString("Process 1 given msecs: ");
     GotoXY(35, middleRow-2);
     WriteString("Process 2 given msecs: ");

     LeftMSec := 0;
     RightMSec := 0;

     Scheduler;

     GotoXY(0, 17);
     CenterStr("Coroutines can multi-task in DOS!");
     GotoXY(0, 19);
     CenterStr("By Fritz Feuerbacher");

     GotoXY(0, 21);
     CenterStr("Press any key");
     PressKey;
     CursorOn;
     CLS;

END DisplayFigures.
