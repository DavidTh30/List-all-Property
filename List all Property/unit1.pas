unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SerialPort,
  typinfo;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;
    SerialPortDriver1: TSerialPortDriver;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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

end.

