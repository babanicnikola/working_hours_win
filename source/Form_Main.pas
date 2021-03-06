unit Form_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, Grids, DBGrids, StdCtrls, ExtCtrls, DBCtrls,
  OleServer, AccessXP, comobj, FMTBcd, SqlExpr, jpeg, ComCtrls;

type
  TFormMain = class(TForm)
    MainConnection: TADOConnection;
    Table1: TADOTable;
    Edit1: TEdit;
    Panel1: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Panel2: TPanel;
    Label1: TLabel;
    Panel3: TPanel;
    Label2: TLabel;
    Button2: TButton;
    Panel4: TPanel;
    Panel5: TPanel;
    Label3: TLabel;
    Edit5: TEdit;
    Button3: TButton;
    Label6: TLabel;
    Edit4: TEdit;
    Button4: TButton;
    Edit2: TEdit;
    Edit3: TEdit;
    Button1: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Panel8: TPanel;
    Button7: TButton;
    Label11: TLabel;
    Edit10: TEdit;
    Panel9: TPanel;
    Label12: TLabel;
    Edit11: TEdit;
    Button8: TButton;
    Label7: TLabel;
    Edit6: TEdit;
    Label8: TLabel;
    Edit7: TEdit;
    MonthCalendar1: TMonthCalendar;
    Label9: TLabel;
    Table2: TADOTable;
    Edit8: TEdit;
    procedure Edit1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure MonthCalendar1Click(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;
  buttonSelected : Integer;
  datum: string;
  ime: string;
implementation

{$R *.dfm}

procedure TFormMain.Edit1Change(Sender: TObject);
begin
  IF Edit1.Text <> '' THEN
    Begin
        table1.Filter:= Format('Ime LIKE ''%s%%''',[Edit1.Text]);
        table1.Filtered:=true;
        Edit1.SetFocus;
    End
  ELSE
    table1.Filtered:=false;
end;

procedure TFormMain.FormActivate(Sender: TObject);
begin
  DBGrid1.Columns[0].Visible:=False;
  while not Table1.Eof do
    begin
      table1.edit;
      Table1.FieldByName('Vrednost EUR').AsFloat := 0;
      Table1.FieldByName('Vrednost RSD').AsFloat := 0;
      table1.Post;
      table1.Refresh;
      Table1.Next;
    end;
end;

procedure TFormMain.Button1Click(Sender: TObject);
begin
  if (edit2.text='') then
    ShowMessage('Unesi ime!')
  else
  if (edit3.text='') then
    ShowMessage('Unesi broj radnih sati!')
  else
  if (edit7.text='') then
    ShowMessage('Unesi cenu za radni sat!')
  else
    begin
      table1.Open;
      table1.Append;
      table1.FieldValues['ime']:= edit2.Text;
      table1.FieldValues['radnih sati']:= edit3.Text;
      table1.FieldValues['cena po satu eur']:= edit7.Text;
      table1.FieldValues['vrednost eur']:= 0;
      table1.FieldValues['vrednost rsd']:= 0;
      table1.Post;
      edit2.text:='';
      edit3.text:='';
      edit7.text:='';
    end;
end;

procedure TFormMain.Button2Click(Sender: TObject);
begin
  buttonSelected := messagedlg('Da li ste sigurni?',mtCustom,
                              [mbYes,mbCancel], 0);

  // Show the button type selected
  if buttonSelected = mrYes then
    begin
      Table1.Locate('ime', 'radnih sati', [loPartialKey]);
      Table1.Delete;
    end;
end;

procedure TFormMain.Button3Click(Sender: TObject);
begin
  datum := DateToStr(MonthCalendar1.Date);
  if (edit5.text='') then
    ShowMessage('Dodaj sate!')
  else
with Table1 do
  begin
    Locate('ime', 'radnih sati', [loPartialKey]);
    Edit;
    FieldByName('radnih sati').AsInteger:=FieldByName('radnih sati').AsInteger + strtoint(edit5.Text);
    Post;
    Refresh;
  end;
  table2.Append;
      table2.FieldValues['ime']:= Table1.FieldByName('ime').AsString;
      table2.FieldValues['datum']:= datum;
      table2.FieldValues['sati']:= edit5.Text;
   edit5.text:='';
end;

procedure TFormMain.Button4Click(Sender: TObject);
begin
  if (edit4.text='') then
    ShowMessage('Unesi sate!')
  else
  with Table1 do
  begin
    Locate('ime', 'radnih sati', [loPartialKey]);
    Edit;
    FieldByName('radnih sati').AsInteger:=FieldByName('radnih sati').AsInteger - strtoint(edit4.Text);
    Post;
    Refresh;
  end;
  edit4.text:='';
end;

procedure TFormMain.Button7Click(Sender: TObject);
var
  bm: TBookmark;
  Total, x ,y : Extended;
BEGIN
  if (edit6.text='') then
    ShowMessage('Unesi kurs!')
  else
  BEGIN
    bm := Table1.GetBookmark;
    Table1.DisableControls;
try
    Total := 1;
    Table1.First;
    while not Table1.Eof do
    begin
      x:=Table1.FieldByName('radnih sati').AsFloat;
      y:=Table1.FieldByName('cena po satu eur').AsFloat;
      Total := x * y;
      table1.edit;
      Table1.FieldByName('Vrednost EUR').AsFloat := Total;
      Table1.FieldByName('Vrednost RSD').AsFloat := Total * StrToFloat(Edit6.text);
      table1.Post;
      table1.Refresh;
      Total:=1;
      Table1.Next;
    end;
  finally
    Table1.GotoBookmark(bm);
    Table1.EnableControls;
  end;
  //Krajnja kalkulacija
  bm := Table1.GetBookmark;
  Table1.DisableControls;
  try
    Total := 0;
    Table1.First;
    while not Table1.Eof do
    begin
      Total := Total + Table1.FieldByName('Vrednost EUR').AsFloat;
      Table1.Next;
    end;
    Total := Total * StrToFloat(Edit6.Text);
    Edit10.Text := FloatToStr(Total);
  finally
    Table1.GotoBookmark(bm);
    Table1.EnableControls;
  end;
end;
END;
procedure TFormMain.Button8Click(Sender: TObject);
begin
  if (edit11.text='') then
    ShowMessage('Unesi novu cenu!')
  else
  with Table1 do
  begin
    Edit;
    FieldByName('cena po satu eur').AsFloat:= strtofloat(edit11.Text);
    Post;
    Refresh;
  end;
  edit11.text:='';
END;
procedure TFormMain.MonthCalendar1Click(Sender: TObject);
begin
    datum := DateToStr(MonthCalendar1.Date);
    ime:=Table1.FieldByName('ime').AsString;
    Edit8.Text:='0';
    Table2.Open;
    Table2.First;
    while not Table2.Eof do
    begin
      IF(Table2.FieldByName('ime').AsString = ime) THEN
        IF(Table2.FieldByName('datum').AsString = datum) THEN
            Edit8.Text:=Table2.FieldByName('sati').AsString;

      Table2.Next;
    end;

end;

procedure TFormMain.DBGrid1CellClick(Column: TColumn);
    var
    datum: string;
    ime: string;
begin
    datum := DateToStr(MonthCalendar1.Date);
    ime:=Table1.FieldByName('ime').AsString;
    Edit8.Text:='0';
    Table2.Open;
    Table2.First;
    while not Table2.Eof do
    begin
      IF(Table2.FieldByName('ime').AsString = ime) THEN
        IF(Table2.FieldByName('datum').AsString = datum) THEN
            Edit8.Text:=Table2.FieldByName('sati').AsString;

      Table2.Next;
    end;
end;

end.

