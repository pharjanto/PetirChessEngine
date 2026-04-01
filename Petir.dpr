program Skakmaster2;

{%ToDo 'Skakmaster2.todo'}
{%ToDo 'Petir.todo'}

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  udata in 'udata.pas',
  bitboard_mask in 'bitboard_mask.pas',
  bitboard in 'bitboard.pas',
  movgen in 'movgen.pas',
  makemove in 'makemove.pas',
  header in 'header.pas',
  tools in 'tools.pas',
  search in 'search.pas',
  ueval in 'ueval.pas',
  next in 'next.pas',
  hashing in 'hashing.pas',
  evalmask in 'evalmask.pas',
  usee in 'usee.pas',

  valid in 'valid.pas',
  hashing_header in 'hashing_header.pas',
  ETC in 'ETC.pas',
  notation in 'notation.pas',
  PV in 'PV.pas',
  uiterative in 'uiterative.pas',
  root in 'root.pas',

  repetition in 'repetition.pas',
  opening_book in 'opening_book.pas',

  winboard in 'winboard.pas';

begin
  Application.Initialize;

  Application.Title := 'Petir';
  Application.CreateForm(TForm1, Form1);
  //  Application.CreateForm(TForm10, Form10);
  Application.Run;
end.
