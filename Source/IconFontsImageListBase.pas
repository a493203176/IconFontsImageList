{******************************************************************************}
{                                                                              }
{       Icon Fonts ImageList: An extended ImageList for Delphi/VCL             }
{       to simplify use of Icons (resize, colors and more...)                  }
{                                                                              }
{       Copyright (c) 2019-2020 (Ethea S.r.l.)                                 }
{       Author: Carlo Barazzetta                                               }
{       Contributors:                                                          }
{         Nicola Tambascia                                                     }
{         Luca Minuti                                                          }
{                                                                              }
{       https://github.com/EtheaDev/IconFontsImageList                         }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}
unit IconFontsImageListBase;

interface

{$INCLUDE IconFontsImageList.inc}

uses
  Classes
  , ImgList
  , Windows
  , Graphics
{$IFDEF D10_4+}
  , System.UITypes
{$ENDIF}
{$IFDEF HiDPISupport}
  , Messaging
{$ENDIF}
{$IFDEF GDI+}
  , Winapi.GDIPOBJ
  , Winapi.GDIPAPI
{$ENDIF}
  , IconFontsItems
  , Controls
  , Forms;

resourcestring
  ERR_ICONFONTS_FONT_NOT_INSTALLED = 'Font "%s" is not installed!';

const
  IconFontsImageListVersion = '2.2.0';
  DEFAULT_SIZE = 16;

type
  TIconFontMissing = procedure (const AFontName: TFontName) of object;

  {TIconFontsImageListBase}
  TDrawIconEvent = procedure (const ASender: TObject; const ACount: Integer;
    const AItem: TIconFontItem) of Object;

  TIconFontsImageListBase = class(TDragImageList)
  private
    FStopDrawing: Integer;
    FFontName: TFontName;
    FMaskColor: TColor;
    FFontColor: TColor;
    FOnFontMissing: TIconFontMissing;
    FFontNamesChecked: TStrings;
    FOnDrawIcon: TDrawIconEvent;
    FIconsAdded: Integer;
    FDisabledFactor: Byte;
    {$IFDEF GDI+}
    FOpacity: Byte;
    {$ENDIF}
    {$IFDEF HiDPISupport}
    FScaled: Boolean;
    FDPIChangedMessageID: Integer;
    {$ENDIF}
    function GetNames(Index: Integer): string;
    procedure SetIconSize(const ASize: Integer);
    procedure SetFontColor(const AValue: TColor);
    procedure SetFontName(const AValue: TFontName);
    procedure SetMaskColor(const AValue: TColor);
    function GetSize: Integer;
    procedure SetSize(const AValue: Integer);
    procedure SetNames(Index: Integer; const Value: string);
    function GetHeight: Integer;
    function GetWidth: Integer;
    procedure SetHeight(const AValue: Integer);
    procedure SetWidth(const AValue: Integer);
    function IsCharAvailable(const ABitmap: TBitmap;
      const AFontIconDec: Integer): Boolean;
    function StoreWidth: Boolean;
    function StoreHeight: Boolean;
    function StoreSize: Boolean;
    {$IFDEF HiDPISupport}
    procedure DPIChangedMessageHandler(const Sender: TObject; const Msg: Messaging.TMessage);
    {$ENDIF}

    {$IFDEF GDI+}
    procedure SetOpacity(const Value: Byte);
    {$ENDIF}
    procedure SetDisabledFactor(const Value: Byte);
  protected
    //Events for notification from item to imagelist
    procedure CheckFontName(const AFontName: TFontName);
    procedure OnItemChanged(Sender: TIconFontItem);
    procedure GetOwnerAttributes(out AFontName: TFontName;
      out AFontColor, AMaskColor: TColor);

    function GetCount: Integer; {$IFDEF DXE8+}override;{$ELSE}virtual;{$ENDIF}
    procedure SetIconFontItems(const AValue: TIconFontItems);
    function GetIconFontItems: TIconFontItems; virtual; abstract;
    {$IFDEF GDI+}
    procedure DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer;
      Style: Cardinal; Enabled: Boolean = True); override;
    {$ENDIF}
    procedure Loaded; override;
  public
    procedure RecreateBitmaps; virtual;
    procedure StopDrawing(const AStop: Boolean);
    procedure DPIChanged(Sender: TObject; const OldDPI, NewDPI: Integer); virtual;
    procedure Change; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Delete(const AIndex: Integer);
    procedure Replace(const AIndex: Integer; const AChar: WideChar;
      const AFontName: TFontName = ''; const AFontColor: TColor = clDefault;
      AMaskColor: TColor = clNone); overload;
    procedure Replace(const AIndex: Integer; const AChar: Integer;
      const AFontName: TFontName = ''; const AFontColor: TColor = clDefault;
      AMaskColor: TColor = clNone); overload;
    function AddIcon(const AChar: Integer; const AIconName: string;
      const AFontName: TFontName = ''; const AFontColor: TColor = clDefault;
      const AMaskColor: TColor = clNone): TIconFontItem; overload;
    function AddIcon(const AChar: WideChar; const AFontName: TFontName = '';
      const AFontColor: TColor = clDefault; const AMaskColor: TColor = clNone): TIconFontItem; overload;
    function AddIcon(const AChar: Integer; const AFontName: TFontName = '';
      const AFontColor: TColor = clDefault; const AMaskColor: TColor = clNone): TIconFontItem; overload;
    //Multiple icons methods
    function AddIcons(const AFrom, ATo: WideChar; const AFontName: TFontName = '';
      const AFontColor: TColor = clDefault; AMaskColor: TColor = clNone;
      const ACheckValid: Boolean = False): Integer;  overload;
    function AddIcons(const AFrom, ATo: Integer; const AFontName: TFontName = '';
      const AFontColor: TColor = clDefault; AMaskColor: TColor = clNone;
      const ACheckValid: Boolean = False): Integer;  overload;
    function AddIcons(const ASourceString: WideString;
      const AFontName: TFontName = ''): Integer; overload;
    procedure UpdateIconsAttributes(const AFontColor, AMaskColor: TColor;
      const AReplaceFontColor: Boolean = False; const AFontName: TFontName = ''); overload;
    procedure UpdateIconsAttributes(const ASize: Integer; const AFontColor, AMaskColor: TColor;
      const AReplaceFontColor: Boolean = False; const AFontName: TFontName = ''); overload;
    procedure ClearIcons; virtual;
    procedure RedrawImages; virtual;
    procedure SaveToFile(const AFileName: string);
    procedure PaintTo(const ACanvas: TCanvas; const AIndex: Integer;
      const X, Y, AWidth, AHeight: Integer;
      const AEnabled: Boolean = True;
      const ADisabledFactor: Byte = 100); overload;
    procedure PaintTo(const ACanvas: TCanvas; const AName: string;
      const X, Y, AWidth, AHeight: Integer;
      const AEnabled: Boolean = True;
      const ADisabledFactor: Byte = 100); overload;
    {$IFDEF D10_4+}
    function IsImageNameAvailable: Boolean; override;
    function IsScaled: Boolean; override;
    function GetIndexByName(const AName: TImageName): TImageIndex; override;
    function GetNameByIndex(AIndex: TImageIndex): TImageName; override;
    {$ENDIF}

    property Names[Index: Integer]: string read GetNames write SetNames;
    property Count: Integer read GetCount;
    property IconFontItems: TIconFontItems read GetIconFontItems write SetIconFontItems;
  published
    {$IFDEF D2010+}
    property ColorDepth default cd32Bit;
    {$ENDIF}
    //Publishing properties of standard ImageList
    property Width: Integer read GetWidth write SetWidth stored StoreWidth default DEFAULT_SIZE;
    property Height: Integer read GetHeight write SetHeight stored StoreHeight default DEFAULT_SIZE;

    property OnChange;
    //New properties
    property DisabledFactor: Byte read FDisabledFactor write SetDisabledFactor default 100;
    property FontName: TFontName read FFontName write SetFontName;
    property FontColor: TColor read FFontColor write SetFontColor default clNone;
    property MaskColor: TColor read FMaskColor write SetMaskColor default clNone;
    {$IFDEF GDI+}
    property Opacity: Byte read FOpacity write SetOpacity default 255;
    {$ENDIF}
    property OnFontMissing: TIconFontMissing read FOnFontMissing write FOnFontMissing;
    property OnDrawIcon: TDrawIconEvent read FOnDrawIcon write FOnDrawIcon;
    property Size: Integer read GetSize write SetSize stored StoreSize default DEFAULT_SIZE;
    {$IFDEF HasStoreBitmapProperty}
    property StoreBitmap default False;
    {$ENDIF}
    {$IFDEF HiDPISupport}
    property Scaled: Boolean read FScaled write FScaled default True;
    {$ENDIF}
  end;

implementation

uses
  SysUtils
  , IconFontsUtils
  , Math
  , ComCtrls
  {$IFDEF DXE3+}
  , System.Character
  , Themes
  {$ENDIF}
  {$IFDEF GDI+}
  , Winapi.CommCtrl
  {$ENDIF}
  , StrUtils
  ;

{$IFDEF GDI+}
function GPColor(Col: TColor; Alpha: Byte): TGPColor;

type
  TInvRGBQUAD = packed record
  rgbRed: Byte;
  rgbGreen: Byte;
  rgbBlue: Byte;
  rgbReserved: Byte;
end;

var
  rec: TInvRGBQuad;
  rec2: TRGBQuad;
  ciCol: Cardinal;
begin
  { This will get the RGB color from a system colour, then we can
  convert this value to a GDI+ colour }
  rec := TInvRGBQuad(Col);
  if rec.rgbReserved = 128 then // $80 then {or =128}
  begin
  ciCol := $80000000 XOR DWORD(Col);
  ciCol := GetSysColor(ciCol);
  rec2 := TRGBQuad(ciCol);
  { Could also just use REC here, and pass Blue where red is
  requested, and Red where blue is requested, should probably
  still result in the same effect }
  Result := MakeColor(Alpha, rec2.rgbRed, rec2.rgbGreen, rec2.rgbBlue);
  end else
  Result := MakeColor(Alpha, rec.rgbRed, rec.rgbGreen, rec.rgbBlue);
end;

procedure TIconFontsImageListBase.DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer;
  Style: Cardinal; Enabled: Boolean);
begin
  PaintTo(Canvas, Index, X, Y, Width, Height, Enabled);
end;

{ TIconFontsImageListBase }

procedure TIconFontsImageListBase.SetOpacity(const Value: Byte);
begin
  if FOpacity <> Value then
  begin
    FOpacity := Value;
    RecreateBitmaps;
  end;
end;
{$ENDIF}

procedure TIconFontsImageListBase.ClearIcons;
begin
  StopDrawing(True);
  try
    if Assigned(IconFontItems) then
      IconFontItems.Clear;
    Clear;
  finally
    StopDrawing(False);
  end;
end;

constructor TIconFontsImageListBase.Create(AOwner: TComponent);
begin
  inherited;
  {$IFDEF D2010+}
  ColorDepth := cd32Bit;
  {$ENDIF}
  FStopDrawing := 0;
  FFontColor := clNone;
  FMaskColor := clNone;
  FDisabledFactor := 100;
  {$IFDEF GDI+}
  FOpacity := 255;
  {$ENDIF}
  FFontNamesChecked := TStringList.Create;
  {$IFDEF HasStoreBitmapProperty}
  StoreBitmap := False;
  {$ENDIF}
  {$IFDEF HiDPISupport}
  FScaled := True;
  FDPIChangedMessageID := TMessageManager.DefaultManager.SubscribeToMessage(TChangeScaleMessage, DPIChangedMessageHandler);
  {$ENDIF}
end;

procedure TIconFontsImageListBase.Delete(const AIndex: Integer);
begin
  //Don't call inherited method of ImageList, to avoid errors
  if Assigned(IconFontItems) then
    IconFontItems.Delete(AIndex);
end;

destructor TIconFontsImageListBase.Destroy;
begin
  {$IFDEF HiDPISupport}
  TMessageManager.DefaultManager.Unsubscribe(TChangeScaleMessage, FDPIChangedMessageID);
  {$ENDIF}
  FreeAndNil(FFontNamesChecked);
  inherited;
end;

procedure TIconFontsImageListBase.Change;
begin
  //Optimization: Do not notify to components during redrawing of icons
  if FStopDrawing = 0 then
    inherited;
end;

procedure TIconFontsImageListBase.CheckFontName(const AFontName: TFontName);
begin
  if AFontName <> '' then
  begin
    if FFontNamesChecked.IndexOf(AFontName) = -1 then //Speed-up check of a Font already checked
    begin
      FFontNamesChecked.Add(AFontName);
      if (Screen.Fonts.IndexOf(AFontName) = -1) then
      begin
        if Assigned(OnFontMissing) then
          OnFontMissing(AFontName)
        else if not (csDesigning in ComponentState) then
          raise Exception.CreateFmt(ERR_ICONFONTS_FONT_NOT_INSTALLED,[AFontName]);
      end
      else
        FFontNamesChecked.Add(AFontName);
    end;
  end;
end;

procedure TIconFontsImageListBase.DPIChanged(Sender: TObject; const OldDPI, NewDPI: Integer);
var
  LSizeScaled: Integer;
begin
  LSizeScaled := MulDiv(Size, NewDPI, OldDPI);
  {$IFDEF D10_3+}
  FScaling := True;
  try
    SetSize(LSizeScaled);
  finally
    FScaling := False;
  end;
  {$ELSE}
    SetSize(LSizeScaled);
  {$ENDIF}
end;

{$IFDEF HiDPISupport}
procedure TIconFontsImageListBase.DPIChangedMessageHandler(const Sender: TObject;
  const Msg: Messaging.TMessage);
var
  LWidthScaled, LHeightScaled: Integer;
begin
  if FScaled and (TChangeScaleMessage(Msg).Sender = Owner) then
  begin
    LWidthScaled := MulDiv(Width, TChangeScaleMessage(Msg).M, TChangeScaleMessage(Msg).D);
    LHeightScaled := MulDiv(Height, TChangeScaleMessage(Msg).M, TChangeScaleMessage(Msg).D);
    FScaling := True;
    try
      if (Width <> LWidthScaled) or (Height <> LHeightScaled) then
      begin
        StopDrawing(True);
        try
          Width := LWidthScaled;
          Height := LHeightScaled;
        finally
          StopDrawing(False);
        end;
        RecreateBitmaps;
      end;
    finally
      FScaling := False;
    end;
  end;
end;
{$ENDIF}

procedure TIconFontsImageListBase.SetDisabledFactor(const Value: Byte);
begin
  if FDisabledFactor <> Value then
  begin
    FDisabledFactor := Value;
  end;
end;

procedure TIconFontsImageListBase.SetFontColor(const AValue: TColor);
begin
  if FFontColor <> AValue then
  begin
    FFontColor := AValue;
    UpdateIconsAttributes(FFontColor, FMaskColor, False);
  end;
end;

procedure TIconFontsImageListBase.SetFontName(const AValue: TFontName);
begin
  if FFontName <> AValue then
  begin
    FFontName := AValue;
    UpdateIconsAttributes(FFontColor, FMaskColor, False);
  end;
end;

function TIconFontsImageListBase.GetCount: Integer;
begin
  if Assigned(IconFontItems) then
    Result := IconFontItems.Count
  else
    Result := 0;
end;

procedure TIconFontsImageListBase.SetHeight(const AValue: Integer);
begin
  if Height <> AValue then
  begin
    inherited Height := AValue;
    RecreateBitmaps;
  end;
end;

function TIconFontsImageListBase.GetNames(Index: Integer): string;
begin
  if (Index >= 0) and Assigned(IconFontItems) and (Index < IconFontItems.Count) then
    Result := IconFontItems[Index].IconName
  else
    Result := '';
end;

procedure TIconFontsImageListBase.SetIconFontItems(const AValue: TIconFontItems);
begin
  if Assigned(IconFontItems) then
    IconFontItems.Assign(AValue);
end;

procedure TIconFontsImageListBase.SetIconSize(const ASize: Integer);
begin
  if Width <> ASize then
    inherited Width := ASize;
  if Height <> ASize then
    inherited Height := ASize;
end;

procedure TIconFontsImageListBase.SetMaskColor(const AValue: TColor);
begin
  if FMaskColor <> AValue then
  begin
    FMaskColor := AValue;
    UpdateIconsAttributes(FFontColor, FMaskColor, False);
  end;
end;

procedure TIconFontsImageListBase.SetSize(const AValue: Integer);
begin
  if (AValue <> Height) or (AValue <> Width) then
  begin
    StopDrawing(True);
    try
      SetIconSize(AValue);
    finally
      StopDrawing(False);
    end;
  RecreateBitmaps;
  end;
end;

procedure TIconFontsImageListBase.SetWidth(const AValue: Integer);
begin
  if Width <> AValue then
  begin
    inherited Width := AValue;
    RecreateBitmaps;
  end;
end;

procedure TIconFontsImageListBase.StopDrawing(const AStop: Boolean);
begin
  if AStop then
    Inc(FStopDrawing)
  else
    Dec(FStopDrawing);
end;

function TIconFontsImageListBase.AddIcon(const AChar: WideChar;
  const AFontName: TFontName = ''; const AFontColor: TColor = clDefault;
  const AMaskColor: TColor = clNone): TIconFontItem;
begin
  Result := AddIcon(Ord(AChar), AFontName, AFontColor, AMaskColor);
end;

procedure TIconFontsImageListBase.PaintTo(const ACanvas: TCanvas;
  const AIndex: Integer;
  const X, Y, AWidth, AHeight: Integer;
  const AEnabled: Boolean = True;
  const ADisabledFactor: Byte = 100);
var
{$IFNDEF GDI+}
  LMaskColor: TColor;
{$ENDIF}
  LItem: TIconFontItem;
begin
  if (AIndex >= 0) and Assigned(IconFontItems) and (AIndex < IconFontItems.Count) then
  begin
    LItem := IconFontItems[AIndex];

    {$IFDEF GDI+}
    LItem.PaintTo(ACanvas, X, Y, AWidth, AHeight, AEnabled, ADisabledFactor, FOpacity);
    {$ELSE}
    LItem.PaintTo(ACanvas, X, Y, AWidth, AHeight, LMaskColor, AEnabled, ADisabledFactor);
    {$ENDIF}
  end;
end;

procedure TIconFontsImageListBase.PaintTo(const ACanvas: TCanvas; const AName: string;
  const X, Y, AWidth, AHeight: Integer;
  const AEnabled: Boolean = True;
  const ADisabledFactor: Byte = 100);
var
  LIndex: Integer;
begin
  if Assigned(IconFontItems) then
  begin
    LIndex := IconFontItems.IndexOf(Name);
    PaintTo(ACanvas, LIndex, X, Y, AWidth, AHeight,
      AEnabled, ADisabledFactor);
  end;
end;

function TIconFontsImageListBase.AddIcon(const AChar: Integer;
  const AFontName: TFontName = '';
  const AFontColor: TColor = clDefault;
  const AMaskColor: TColor = clNone): TIconFontItem;
begin
  Result := AddIcon(AChar, '', AFontName, AFontColor, AMaskColor);
end;

function TIconFontsImageListBase.AddIcon(const AChar: Integer;
  const AIconName: string; const AFontName: TFontName = '';
  const AFontColor: TColor = clDefault;
  const AMaskColor: TColor = clNone): TIconFontItem;
begin
  if Assigned(IconFontItems) then
  begin
    Result := IconFontItems.Add;
    try
      Result.IconName := AIconName;
      Result.FontIconDec := AChar;
      if (AFontName <> '') and (AFontName <> FontName) then
        Result.FontName := AFontName;
      if AFontColor <> clDefault then
        Result.FontColor := AFontColor;
      if AMaskColor <> clNone then
        Result.MaskColor := AMaskColor;
    except
      IconFontItems.Delete(Result.Index);
      raise;
    end;
  end
  else
    Result := nil;
end;

function TIconFontsImageListBase.AddIcons(const AFrom, ATo: WideChar;
  const AFontName: TFontName = '';
  const AFontColor: TColor = clDefault; AMaskColor: TColor = clNone;
  const ACheckValid: Boolean = False): Integer;
begin
  Result := AddIcons(Ord(AFrom), Ord(ATo), AFontName, AFontColor, AMaskColor, ACheckValid);
end;

function TIconFontsImageListBase.AddIcons(const AFrom, ATo: Integer;
  const AFontName: TFontName = '';
  const AFontColor: TColor = clDefault; AMaskColor: TColor = clNone;
  const ACheckValid: Boolean = False): Integer;
var
  LChar: Integer;
  LFontName: TFontName;
  LIsValid: Boolean;
  LBitmap: TBitmap;
begin
  CheckFontName(AFontName);
  StopDrawing(True);
  LBitmap := nil;
  try
    Result := 0;
    if ACheckValid then
    begin
      if AFontName <> '' then
        LFontName := AFontName
      else
        LFontName := FFontName;
      LBitmap := TBitmap.Create;
      LBitmap.Width := 10;
      LBitmap.Height := 10;
      with LBitmap.Canvas do
      begin
        Font.Name := LFontName;
        Font.Height := 10;
        Font.Color := clBlack;
        Brush.Color := clWhite;
      end;
    end;
    FIconsAdded := 0;
    for LChar := AFrom to ATo do
    begin
      if ACheckValid then
        LIsValid := IsFontIconValidValue(LChar) and IsCharAvailable(LBitmap, LChar)
      else
        LIsValid := IsFontIconValidValue(LChar);
      if LIsValid then
      begin
        AddIcon(LChar, AFontName, AFontColor, AMaskColor);
        Inc(Result);
      end;
    end;
    FIconsAdded := Result;
  finally
    LBitmap.Free;
    StopDrawing(False);
  end;
  RecreateBitmaps;
end;

procedure TIconFontsImageListBase.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TIconFontsImageListBase then
  begin
    StopDrawing(True);
    try
      FFontName := TIconFontsImageListBase(Source).FontName;
      FFontColor := TIconFontsImageListBase(Source).FontColor;
      FMaskColor := TIconFontsImageListBase(Source).FMaskColor;

      {$IFDEF GDI+}
      FDisabledFactor := TIconFontsImageListBase(Source).FDisabledFactor;
      FOpacity := TIconFontsImageListBase(Source).FOpacity;
      {$ENDIF}

      {$IFDEF HasStoreBitmapProperty}
      StoreBitmap := TIconFontsImageListBase(Source).StoreBitmap;
      {$ENDIF}
      Width := TIconFontsImageListBase(Source).Width;
      Height := TIconFontsImageListBase(Source).Height;
      if Assigned(IconFontItems) and Assigned(TIconFontsImageListBase(Source).IconFontItems) then
        IconFontItems.Assign(TIconFontsImageListBase(Source).IconFontItems);
    finally
      StopDrawing(False);
    end;
    RecreateBitmaps;
  end;
end;

function TIconFontsImageListBase.IsCharAvailable(
  const ABitmap: TBitmap;
  const AFontIconDec: Integer): Boolean;
var
  Cnt: DWORD;
  len: Integer;
  buf : array of WORD;
  I: Integer;
  S: WideString;
  msBlank, msIcon: TMemoryStream;
  LIsSurrogate: Boolean;
  LRect: TRect;
begin
  Result := False;
  if Assigned(ABitmap) then
  begin
    LIsSurrogate := (AFontIconDec >= $010000) and (AFontIconDec <= $10FFFF);
    if LIsSurrogate then
    begin
      //To support surrogate Characters I cannot use GetGlyphIndicesW so I'm drawing the Character on a Canvas and
      //check if is already blank: this method is quite slow
      LRect := Rect(0,0, ABitmap.Width, ABitmap.Height);
      ABitmap.Canvas.FillRect(LRect);
      msBlank := TMemoryStream.Create;
      msIcon := TMemoryStream.Create;
      try
        ABitmap.SaveToStream(msBlank);
        {$IFDEF DXE3+}
        {$WARN SYMBOL_DEPRECATED OFF}
        S := ConvertFromUtf32(AFontIconDec);
        {$WARN SYMBOL_DEPRECATED ON}
        ABitmap.Canvas.TextOut(0, 0, S);
        {$ELSE}
        S := WideChar(AFontIconDec);
        TextOutW(ABitmap.Canvas.Handle, 0, 0, PWideChar(S), 1);
        {$ENDIF}
        ABitmap.SaveToStream(msIcon);
        Result := not ((msBlank.Size = msIcon.Size) and CompareMem(msBlank.Memory, msIcon.Memory, msBlank.Size));
      finally
        msBlank.Free;
        msIcon.Free;
      end;
    end
    else
    begin
      //Check for non surrogate pairs, using GetGlyphIndices
      S := WideChar(AFontIconDec);
      len := Length(S);
      SetLength( buf, len);
      {$IFDEF D2010+}
      Cnt := GetGlyphIndicesW( ABitmap.Canvas.Handle, PWideChar(S), len, @buf[0], GGI_MARK_NONEXISTING_GLYPHS);
      {$ELSE}
      {$WARN SUSPICIOUS_TYPECAST OFF}
      Cnt := GetGlyphIndicesW( ABitmap.Canvas.Handle, PAnsiChar(S), len, @buf[0], GGI_MARK_NONEXISTING_GLYPHS);
      {$ENDIF}
      if Cnt > 0 then
      begin
        for i := 0 to Cnt-1 do
          Result := buf[i] <> $FFFF;
      end;
    end;
  end;
end;

procedure TIconFontsImageListBase.SaveToFile(const AFileName: string);
var
  LImageStrip: TBitmap;
  LImageCount: Integer;
  LStripWidth, LStripHeight: Integer;

  procedure CreateLImageStrip(var AStrip: TBitmap);
  var
    I, J, K: Integer;
  begin
    with AStrip do
    begin
      Canvas.Brush.Color := MaskColor;
      Canvas.FillRect(Rect(0, 0, AStrip.Width, AStrip.Height));
      J := 0;
      K := 0;
      for I := 0 to Self.Count - 1 do
      begin
        Draw(Canvas, J * Width, K * Height, I, dsTransparent, itImage);
        Inc(J);
        if J >= LStripWidth then
        begin
          J := 0;
          Inc(K);
        end;
      end;
    end;
  end;

  procedure CalcDimensions(ACount: Integer; var AWidth, AHeight: Integer);
  var
    X: Double;
  begin
    X := Sqrt(ACount);
    AWidth := Trunc(X);
    if Frac(X) > 0 then
      Inc(AWidth);
    X := ACount / AWidth;
    AHeight := Trunc(X);
    if Frac(X) > 0 then
      Inc(AHeight);
  end;

begin
  LImageStrip := TBitmap.Create;
  try
    LImageCount := Count;
    CalcDimensions(LImageCount, LStripWidth, LStripHeight);
    LImageStrip.Width := LStripWidth * Size;
    LImageStrip.Height := LStripHeight * Size;
    CreateLImageStrip(LImageStrip);
    LImageStrip.SaveToFile(AFileName);
  finally
    LImageStrip.Free;
  end;
end;

{$IFDEF D10_4+}
function TIconFontsImageListBase.GetIndexByName(
  const AName: TImageName): TImageIndex;
var
  LIconFontItem: TIconFontItem;
begin
  if Assigned(IconFontItems) then
  begin
    LIconFontItem := IconFontItems.GetIconByName(AName);
    if Assigned(LIconFontItem) then
      Result := LIconFontItem.Index
    else
      Result := -1;
  end
  else
    Result := -1;
end;

function TIconFontsImageListBase.GetNameByIndex(AIndex: TImageIndex): TImageName;
begin
  if Assigned(IconFontItems) then
    Result := IconFontItems.Items[AIndex].IconName
  else
    Result := '';
end;

function TIconFontsImageListBase.IsImageNameAvailable: Boolean;
begin
  Result := True;
end;

function TIconFontsImageListBase.IsScaled: Boolean;
begin
  Result := FScaled;
end;
{$ENDIF}

function TIconFontsImageListBase.GetSize: Integer;
begin
  Result := Max(Width, Height);
end;

function TIconFontsImageListBase.GetWidth: Integer;
begin
  Result := inherited Width;
end;

function TIconFontsImageListBase.GetHeight: Integer;
begin
  Result := inherited Height;
end;

procedure TIconFontsImageListBase.Loaded;
begin
  inherited;
  {$IFDEF HasStoreBitmapProperty}
  if (not StoreBitmap) then
    RecreateBitmaps;
  {$ENDIF}
  if (inherited Count = 0) or (csDesigning in ComponentState) then
    RecreateBitmaps;
end;

procedure TIconFontsImageListBase.OnItemChanged(Sender: TIconFontItem);
begin
  RecreateBitmaps;
end;

procedure TIconFontsImageListBase.GetOwnerAttributes(out AFontName: TFontName;
  out AFontColor, AMaskColor: TColor);
begin
  AFontName := FFontName;
  AFontColor := FFontColor;
  AMaskColor := FMaskColor;
end;

procedure TIconFontsImageListBase.SetNames(Index: Integer; const Value: string);
begin
  if (Index >= 0) and (Index < IconFontItems.Count) then
    IconFontItems[Index].IconName := Value;
end;

procedure TIconFontsImageListBase.UpdateIconsAttributes(const ASize: Integer;
  const AFontColor, AMaskColor: TColor; const AReplaceFontColor: Boolean = False;
  const AFontName: TFontName = '');
begin
  if Assigned(IconFontItems) then
  begin
    if (AFontColor <> clNone) and (AMaskColor <> clNone) then
    begin
      StopDrawing(True);
      try
        SetIconSize(ASize);
        FFontColor := AFontColor;
        FMaskColor := AMaskColor;
      finally
        StopDrawing(False);
      end;
      RecreateBitmaps;
    end;
  end;
end;

procedure TIconFontsImageListBase.UpdateIconsAttributes(const AFontColor,
  AMaskColor: TColor; const AReplaceFontColor: Boolean; const AFontName: TFontName);
begin
  UpdateIconsAttributes(Self.Size, AFontColor, AMaskColor, AReplaceFontColor, AFontName);
end;

procedure TIconFontsImageListBase.RedrawImages;
begin
  if FStopDrawing > 0 then
    Exit;
  RecreateBitmaps;
end;

function TIconFontsImageListBase.StoreSize: Boolean;
begin
  Result := (Width = Height) and (Width <> DEFAULT_SIZE);
end;

function TIconFontsImageListBase.StoreWidth: Boolean;
begin
  Result := (Width <> Height) and (Width <> DEFAULT_SIZE);
end;

function TIconFontsImageListBase.StoreHeight: Boolean;
begin
  Result := (Width <> Height) and (Height <> DEFAULT_SIZE);
end;

procedure TIconFontsImageListBase.RecreateBitmaps;
var
  C: Integer;
  LBitmap: TBitmap;
  {$IFNDEF GDI+}
  LMaskColor: TColor;
  {$ENDIF}
  LItem: TIconFontItem;

  procedure AddMaskedBitmap(AIconFontItem: TIconFontItem);
  begin
    LBitmap := TBitmap.Create;
    try
      LBitmap.PixelFormat := pf32bit;
      {$IFDEF DXE+}
      LBitmap.SetSize(Width, Height);
      LBitmap.alphaFormat := afIgnored;
      {$ELSE}
      LBitmap.Width := Width;
      LBitmap.Height := Height;
      {$ENDIF}
      {$IFDEF GDI+}
      AIconFontItem.PaintTo(LBitmap.Canvas, 0, 0, Width, Height,
        True, FDisabledFactor, FOpacity);
      {$ELSE}
      AIconFontItem.PaintTo(LBitmap.Canvas, 0, 0, Width, Height,
        LMaskColor, True, FDisabledFactor);
      AddMasked(LBitmap, LMaskColor);
      {$ENDIF}
    finally
      LBitmap.Free;
    end;
  end;

begin
  if not Assigned(IconFontItems) or
    (FStopDrawing <> 0) or
    (csDestroying in ComponentState) or
    (csLoading in ComponentState) then
    Exit;
  StopDrawing(True);
  try
    begin
      {$IFDEF GDI+}
      ImageList_Remove(Handle, -1);
      if (Width > 0) and (Height > 0) then
      begin
        Handle := ImageList_Create(Width, Height,
          ILC_COLOR32 or (Integer(Masked) * ILC_MASK), 0, AllocBy);

        FIconsAdded := 0;
        for C := 0 to IconFontItems.Count - 1 do
        begin
          LItem := IconFontItems[C];
          if Assigned(LItem) then
          begin
            LBitmap := LItem.GetBitmap(Width, Height, True);
            try
              ImageList_Add(Handle, LBitmap.Handle, 0);
              if Assigned(OnDrawIcon) then
                OnDrawIcon(Self, FIconsAdded, LItem);
            finally
              LBitmap.Free;
            end;
            Inc(FIconsAdded);
          end;
        end;
      end;
      {$ELSE}
      inherited Clear;
      FIconsAdded := 0;
      for C := 0 to IconFontItems.Count -1 do
      begin
        LItem := IconFontItems[C];
        AddMaskedBitmap(LItem);
        if Assigned(OnDrawIcon) then
          OnDrawIcon(Self, FIconsAdded, LItem);
        Inc(FIconsAdded);
      end;
      {$ENDIF}
    end;
  finally
    StopDrawing(False);
    Change;
  end;
end;

procedure TIconFontsImageListBase.Replace(const AIndex: Integer; const AChar: WideChar;
  const AFontName: TFontName; const AFontColor: TColor; AMaskColor: TColor);
begin
  Replace(AIndex, Ord(AChar), AFontName, AFontColor, AMaskColor);
end;

procedure TIconFontsImageListBase.Replace(const AIndex: Integer; const AChar: Integer;
  const AFontName: TFontName; const AFontColor: TColor; AMaskColor: TColor);
var
  LIconFontItem: TIconFontItem;
begin
  if Assigned(IconFontItems) then
  begin
    LIconFontItem := IconFontItems.Items[AIndex];
    if Assigned(LIconFontItem) then
      LIconFontItem.FontIconDec := AChar;
  end;
end;

function TIconFontsImageListBase.AddIcons(const ASourceString: WideString;
  const AFontName: TFontName = ''): Integer;
{$IFDEF DXE3+}
var
  LChar: UCS4Char;
  I, L, ICharLen: Integer;
{$ENDIF}
begin
  Result := 0;
  {$IFDEF DXE3+}
  L := Length(ASourceString);
  I := 1;
  while I <= L do
  begin
    {$WARN SYMBOL_DEPRECATED OFF}
    if IsSurrogate(ASourceString[I]) then
    begin
      LChar := ConvertToUtf32(ASourceString, I, ICharLen);
    end
    else
    begin
      ICharLen := 1;
      LChar := UCS4Char(ASourceString[I]);
    end;
    {$WARN SYMBOL_DEPRECATED ON}
    AddIcon(Ord(LChar), AFontName);
    Inc(I, ICharLen);
    Inc(Result);
  end;
  RedrawImages;
  {$ENDIF}
end;

end.
