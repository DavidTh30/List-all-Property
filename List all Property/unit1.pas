unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  SerialPort, typinfo;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;
    SerialPortDriver1: TSerialPortDriver;
    Splitter1: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

//Setting a value using RTTI
function GetPropInfo(Instance: TObject; const PropName: string): PPropInfo;
begin
  Result := GetPropInfo(Instance, PropName);
end;
// To use GetPropInfo()
//SetOrdProp(Instance,GetPropInfo(Instance),Ord(Value))

function GetCompFont(Component : TComponent) : TFont;
var ptrPropInfo : PPropInfo;
begin
  ptrPropInfo := GetPropInfo(Component, 'Font');
  if ptrPropInfo = nil then
    Result := nil
  else
    Result:=TFont(GetObjectProp(Component,ptrPropInfo,TFont));
end;


procedure ListComponentProperties(Component: TComponent; Strings: TStrings);
var
  Count, Size, I: Integer;
  List: PPropList;
  PropInfo: PPropInfo;
  PropOrEvent, PropValue: string;
begin
  Count := GetPropList(Component.ClassInfo, tkAny, nil);
  Size  := Count * SizeOf(Pointer);
  GetMem(List, Size);
  try
    Count := GetPropList(Component.ClassInfo, tkAny, List);
    for I := 0 to Count - 1 do
    begin
      PropInfo := List^[I];

      if PropInfo^.PropType^.Kind in tkMethods then
        PropOrEvent := 'Event'
      else
        PropOrEvent := 'Property';

      PropValue := GetPropValue(Component, PropInfo^.Name);
      Strings.Add(Format('[%s] %s: %s = %s', [PropOrEvent, PropInfo^.Name,
        PropInfo^.PropType^.Name, PropValue]));
    end;
  finally
    FreeMem(List);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Cnt,Lp: ptrint;
  OrdVal: ptrint;
  StrName,StrVal: String;
  FloatVal: Extended;
  PropInfos: PPropList;
  PropInfo: PPropInfo;
begin
  Memo1.Clear;
  { Find out how many properties we'll be considering and get them }
  Cnt := GetPropList(PTypeInfo(SerialPortDriver1.ClassInfo),PropInfos);
  try
    for Lp:= 0 to Cnt - 1 do begin { Loop through all the selected properties }
      PropInfo:= PropInfos^[Lp];
      StrName:= PropInfo^.Name;
      { Check the general type of the property and read/write it in an appropriate way }
      case PropInfo^.PropType^.Kind of
        tkInt64,tkInteger,tkChar,tkEnumeration,tkBool,tkQWord,
        tkSet,tkClass,tkWChar: begin
                                 OrdVal:= GetOrdProp(SerialPortDriver1,PropInfo);
                                 Memo1.Append('General '+StrName+' '+OrdVal.ToString);
                                 //Ini.WriteInt64('General',StrName,OrdVal);
                               end; { ordinal types }
        tkFloat:               begin
                                 FloatVal:= GetFloatProp(SerialPortDriver1,PropInfo);
                                 Memo1.Append('General '+StrName+' '+FloatVal.ToString);
                                 //Ini.WriteFloat('General',StrName,FloatVal);
                               end; { floating point types }
        tkWString,tkLString,tkAString,
        tkString:              begin
                                 { Avoid copying 'Name' - components must have unique names }
//                                 if UpperCase(PropInfo^.Name) = 'NAME' then Continue;
                                 StrVal:= GetStrProp(SerialPortDriver1,PropInfo);
                                 Memo1.Append('General '+StrName+' '+StrVal);
                                 //Ini.WriteString('General',StrName,StrVal);
                               end; { string types }
        else ;
      end;
    end;
  finally
    FreeMem(PropInfos,Cnt*sizeof(pointer)); { typinfo allocates like this: getmem(PropList,result*sizeof(pointer)); }
  end;
  //Ini.UpdateFile; { persist to disk }
  //Result:= true;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ListComponentProperties(Button1, ListBox1.Items);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  showmessage('Test');
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  TestButton:TButton;
  c: TComponent;
  dd: TControl;
  FoundClass: TPersistentClass;
begin
  FoundClass := FindClass('TButton');
  if (FoundClass = nil) then begin showmessage('FoundClass = nil'); exit; end;

  if (FoundClass <> nil) then
  begin
    if not FoundClass.InheritsFrom(TControl) then begin showmessage('FoundClass not InheritsFrom'); exit; end;

  end;

  c := findcomponent('TestButton');
  if Not (c=nil) then
  begin
    showmessage('Found findcomponent:'+c.ClassName);
    if (c is TButton) then dd:= TControlClass(FoundClass).Create(self);
    if (c is TEdit) then dd:= TEdit(c);
    if (c is TLabel) then dd:= TLabel(c);
    if (c is TMemo) then dd:= TMemo(c);
    dd.Free;
  end;

  TestButton:=TButton.Create(self);
  TestButton.Name:='TestButton';

  c := findcomponent(TestButton.Name);

  if c=nil then begin showmessage('TComponent = nil'); exit; end;
  if (c is TButton) then
  begin
    //dd:= TButton(c);
    dd:= TControlClass(FoundClass).Create(self);
    showmessage('TComponent = TestButton');
    showmessage(dd.Name);
    dd.Left:=Button3.Left;
    dd.Width:=Button3.Width;
    dd.Height:=Button3.Height;
    dd.Top:=Button3.Top+Button3.Height+3;
    dd.Caption:='Copy Button';
    dd.OnClick:=@Button3Click;
    dd.Parent:=form1;
    dd.Visible:=true;

  end;
  TestButton.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);

begin
  RegisterClass(TLabel);
  RegisterClass(TEdit);
  RegisterClass(TButton);
  RegisterClass(TRadioButton);
  RegisterClass(TCheckbox);
  RegisterClass(TMemo);
  Button3.OnClick:=@Button3Click;
end;

end.

