unit calc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DateUtils, strutils, types;

type

  { Tmain }

  Tmain = class(TForm)
    Button1: TButton;
    editTotal: TEdit;
    editOT2: TEdit;
    editOT3: TEdit;
    editPerformance: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    memoOut: TMemo;
    roleBox: TComboBox;
    editRequired: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  main: Tmain;

const
  BasicSalaryNoOT: array of integer = (
    1800,
    2000,
    2000,
    2100,
    2100,
    2200,
    2200,
    2300,
    2500);

  BasicSalary: array of integer = (
    2540,
    2820,
    2820,
    2960,
    2960,
    3100,
    3100,
    3240,
    3520);

  QSC: array of integer = (
    200,
    200,
    200,
    200,
    300,
    300,
    300,
    400,
    500);

  FullRun: array of integer = (
    150,
    150,
    150,
    150,
    150,
    150,
    150,
    200,
    300);

  Food: array of integer = (
    200,
    300,
    300,
    300,
    300,
    300,
    300,
    500,
    600);

  SocialSecurity: array of integer = (
    510,
    510,
    510,
    510,
    510,
    520,
    520,
    520,
    520);

  House: array of integer = (
    0,
    200,
    200,
    200,
    200,
    200,
    200,
    500,
    500);

  Transport: array of integer = (
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    600);

  {Using Position will result in Illegal qualifier}
  Position2: array of integer = (
    0,
    0,
    100,
    200,
    500,
    1000,
    1200,
    1500,
    1800);

  PerformanceIndex: array of real = (
    0,
    1,
    1.5,
    2,
    2.5,
    3,
    5,
    6,
    2);

  RegionalManager = 8;

implementation

{$R *.lfm}

{ Tmain }


procedure Tmain.Button1Click(Sender: TObject);
var
  role: integer;
  required, performance, total, ot2, ot3, tempStr, rmStr: string;
  iRequired, iPerformance, iTotal, iOT2, iOT3: real;
  isFullRun: boolean;
  ot, temp, nOT2, nOT3: real;
  stores: TStringDynArray;
begin
  role := roleBox.ItemIndex;
  if (role < 0) then
  begin
    ShowMessage('选择员工级别');
    exit;
  end;
  required := editRequired.Text;
  performance := editPerformance.Text;
  stores := SplitString(performance, ' ');
  total := editTotal.Text;
  ot2 := editOT2.Text;
  ot3 := editOT3.Text;
  required := required.trim();
  performance := performance.Trim();
  total := total.trim();
  if (required = '') or (performance = '') or (total = '') then
  begin
    ShowMessage('输入本月标准工时，绩效金额，实际工时');
    exit;
  end;
  try
    iRequired := strToFloat(required);
    if role = RegionalManager then
    begin
      temp := 0;
      rmStr := '';
      for tempStr in stores do
      begin
        if tempStr <> '' then
        begin
          temp := strToFloat(tempStr) + temp;
          if rmStr = '' then
            rmStr := '(' + tempStr
          else
            rmStr := rmStr + '+' + tempStr;
        end;
      end;
      if temp = 0 then
      begin
        ShowMessage('输入区域经理对应的正确绩效金额');
        exit;
      end;
      iPerformance := temp;
      performance := rmStr + ')';
    end
    else
      iPerformance := strToFloat(performance);

    iTotal := strToFloat(total);
  except
    ShowMessage('输入正确本月标准工时，绩效金额，实际工时');
    exit;
  end;
  memoOut.Lines.Clear;

  try
    iOT2 := strToFloat(ot2);
  except
    iOT2 := 0;
  end;
  try
    iOT3 := strToFloat(ot3);
  except
    iOT3 := 0;
  end;
  ot2 := floatToStr(iOT2);
  ot3 := floatToStr(iOT3);
  isFullRun := iTotal >= iRequired;
  ot := 0;

  if (isFullRun) then
  begin
    ot := iTotal - iRequired;
    temp := BasicSalary[role];
    memoOut.Lines.Add('基本工资: ' + floatToStr(temp));
  end
  else
  begin
    temp := round(BasicSalary[role] / iRequired * iTotal);
    memoOut.Lines.Add('基本工资: ' + floatToStr(temp) + '   ' +
      IntToStr(BasicSalary[role]) + '/' + required + '*' + total);
  end;

  if (isFullRun) then
  begin
    temp := PerformanceIndex[role] * iPerformance;
    memoOut.Lines.Add('绩效工资: ' + floatToStr(temp) + '   ' +
      floatToStr(PerformanceIndex[role]) + '*' + performance);
  end
  else
  begin
    temp := round(PerformanceIndex[role] * iPerformance / iRequired * iTotal);
    memoOut.Lines.Add('绩效工资: ' + floatToStr(temp) + '   ' +
      floatToStr(PerformanceIndex[role]) + '*' + performance + '/' +
      required + '*' + total);
  end;

  temp := 0;
  if isFullRun then temp := round((BasicSalaryNoOT[role] / 176) * 1.5 * ot);
  if temp > 0 then
    memoOut.Lines.Add('非节日加班费: ' + floatToStr(temp) +
      '   ' + IntToStr(BasicSalaryNoOT[role]) + '/176*1.5*' + floatToStr(ot))
  else
    memoOut.Lines.Add('非节日加班费: ' + floatToStr(temp));

  nOT2 := (BasicSalaryNoOT[role] / 176) * 1 * iOT2;
  nOT3 := (BasicSalaryNoOT[role] / 176) * 2 * iOT3;
  temp := round(nOT2 + nOT3);
  tempStr := '';
  if nOT2 > 0 then tempStr := floatToStr(BasicSalaryNoOT[role]) + '/176*1*' + ot2;
  if nOT3 > 0 then
    if tempStr.isEmpty() then
      tempStr := floatToStr(BasicSalaryNoOT[role]) + '/176*2*' + ot3
    else
      tempStr := tempStr + '+' + floatToStr(BasicSalaryNoOT[role]) + '/176*2*' + ot3;
  memoOut.Lines.Add('节日加班费: ' + floatToStr(temp) + '   ' + tempStr);

  if isFullRun then
  begin
    temp := House[role];
    memoOut.Lines.Add('住房补贴: ' + floatToStr(temp));
  end
  else
  begin
    temp := round(House[role] / iRequired * iTotal);
    memoOut.Lines.Add('住房补贴: ' + floatToStr(temp) + '   ' +
      IntToStr(House[role]) + '/' + required + '*' + total);
  end;

  if isFullRun then
  begin
    temp := Food[role];
    memoOut.Lines.Add('膳食津贴: ' + floatToStr(temp));
  end
  else
  begin
    temp := round(Food[role] / iRequired * iTotal);
    memoOut.Lines.Add('膳食津贴: ' + floatToStr(temp) + '   ' +
      IntToStr(Food[role]) + '/' + required + '*' + total);
  end;

  if isFullRun then
  begin
    temp := SocialSecurity[role];
    memoOut.Lines.Add('社保补贴: ' + floatToStr(temp));
  end
  else
  begin
    temp := round(SocialSecurity[role] / iRequired * iTotal);
    // In the case of .5, the algorithm uses "banker's rounding": .5 values are always rounded towards the even number.
    memoOut.Lines.Add('社保补贴: ' + floatToStr(temp) + '   ' +
      IntToStr(SocialSecurity[role]) + '/' + required + '*' + total);
  end;

  if isFullRun then
  begin
    temp := FullRun[role];
    memoOut.Lines.Add('全勤奖金: ' + floatToStr(temp));
  end
  else
  begin
    temp := round(FullRun[role] / iRequired * iTotal);
    memoOut.Lines.Add('全勤奖金: ' + floatToStr(temp) + '   ' +
      IntToStr(FullRun[role]) + '/' + required + '*' + total +
      '   工时不足！是否新员工或离职员工？');
  end;

  if isFullRun then
  begin
    temp := QSC[role];
    memoOut.Lines.Add('QSC金额: ' + floatToStr(temp));
  end
  else
  begin
    temp := round(QSC[role] / iRequired * iTotal);
    memoOut.Lines.Add('QSC金额: ' + floatToStr(temp) + '   ' +
      IntToStr(QSC[role]) + '/' + required + '*' + total);
  end;

  if isFullRun then
  begin
    temp := 200;
    memoOut.Lines.Add('卫生标兵奖励: ' + floatToStr(temp));
  end
  else
  begin
    temp := round(200 / iRequired * iTotal);
    memoOut.Lines.Add('卫生标兵奖励: ' + floatToStr(temp) +
      '   ' + '200/' + required + '*' + total);
  end;

  if role = RegionalManager then
  begin
    if isFullRun then
    begin
      temp := Transport[role];
      memoOut.Lines.Add('交通补贴: ' + floatToStr(temp));
    end
    else
    begin
      temp := round(Transport[role] / iRequired * iTotal);
      memoOut.Lines.Add('交通补贴: ' + floatToStr(temp) + '   ' +
        IntToStr(Transport[role]) + '/' + required + '*' + total);
    end;
  end;

  if isFullRun then
  begin
    temp := Position2[role];
    memoOut.Lines.Add('管理津贴: ' + floatToStr(temp));
  end
  else
  begin
    temp := round(Position2[role] / iRequired * iTotal);
    memoOut.Lines.Add('管理津贴: ' + floatToStr(temp) + '   ' +
      IntToStr(Position2[role]) + '/' + required + '*' + total);
  end;

end;

procedure Tmain.FormCreate(Sender: TObject);
var
  year, month, day: word;
  strHours: string;
begin
  DecodeDate(incMonth(Date, -1), year, month, day); // last month salary
  day := DaysInAMonth(year, month) - 4;
  strHours := floatToStr(day * 8.5);
  editRequired.Text := strHours;
  editTotal.Text := strHours;
end;

end.
