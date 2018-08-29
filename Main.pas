unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TfrmMain = class(TForm)
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlCount: TPanel;
    btnRefresh: TButton;
    lvProcesses: TListView;
    lvPorts: TListView;
    Splitter1: TSplitter;
    procedure btnRefreshClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvPortsCompare(Sender: TObject; Item1, Item2: TListItem; Data:
        Integer; var Compare: Integer);
    procedure lvProcessesChange(Sender: TObject; Item: TListItem; Change:
        TItemChange);
  private
    procedure FillList;
    procedure GetPortListByPID(const pid: Cardinal);
    procedure UpdateCounterCaption(const tcp, udp: Integer);
  end;

  TMibTcpRowOwnerPid = packed record
    dwState     : DWORD;
    dwLocalAddr : DWORD;
    dwLocalPort : DWORD;
    dwRemoteAddr: DWORD;
    dwRemotePort: DWORD;
    dwOwningPid : DWORD;
  end;
  PMibTcpRowOwnerPid = ^TMibTcpRowOwnerPid;

  MIB_TCPTABLE_OWNER_PID = packed record
   dwNumEntries: DWord;
   table: array [0..0] of TMibTcpRowOwnerPid;
  end;
  PMIB_TCPTABLE_OWNER_PID  = ^MIB_TCPTABLE_OWNER_PID;

  TMibUdpRowOwnerPID = packed record
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwOwningPid: DWORD;
  end;
  PMibUdpRowOwnerPID = ^TMibUdpRowOwnerPID;

  MIB_UDPTABLE_OWNER_PID = packed record
    dwNumEntries: DWORD;
    table: Array[0..0] of TMibUdpRowOwnerPID;
  end;
  PMIB_UDPTABLE_OWNER_PID = ^MIB_UDPTABLE_OWNER_PID;

  function GetExtendedTcpTable(pTcpTable: Pointer; pdwSize: PDWORD; bOrder: BOOL; ulAf: LongWord;
    TableClass: Integer; Reserved: LongWord): DWORD; stdcall; external 'iphlpapi.dll';

  function GetExtendedUdpTable( pUdpTable: Pointer; pdwSize: PDWORD; bOrder: BOOL; ulAf: LongWord;
    TableClass: Integer; Reserved: LongWord): LongInt; stdcall; external 'iphlpapi.dll';

const
  TCP_TABLE_OWNER_PID_ALL = 5;
  UDP_TABLE_OWNER_PID     = 1;
  Counter_Caption         = 'TCP: %d,     UDP: %d';

var
  frmMain: TfrmMain;

implementation

uses TlHelp32, WinSock;

{$R *.dfm}

procedure TfrmMain.FillList;
var
  Snapshot: THandle;
  ProcessEntry: TProcessEntry32;
  aItem: TListItem;
begin
  UpdateCounterCaption(0, 0);

  lvProcesses.Items.BeginUpdate;
  lvProcesses.Clear;
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    ProcessEntry.dwSize := SizeOf(TProcessEntry32);
    if not Process32First(Snapshot, ProcessEntry) then Exit;
    repeat
      aItem := lvProcesses.Items.Add;
      aItem.Caption := ProcessEntry.szExeFile;
      aItem.SubItems.Add(IntToStr(ProcessEntry.th32ProcessID));
    until not Process32Next(Snapshot, ProcessEntry);
  finally
    CloseHandle(Snapshot);
    lvProcesses.Items.EndUpdate;
  end;
end;

procedure TfrmMain.btnRefreshClick(Sender: TObject);
begin
  FillList;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  FillList;
end;

procedure TfrmMain.GetPortListByPID(const pid: Cardinal);
var
  i: integer;
  TableSize: DWORD;
  FExtendedTcpTable: PMIB_TCPTABLE_OWNER_PID;
  FExtendedUdpTable: PMIB_UDPTABLE_OWNER_PID;
  tcp_count, udp_count: Integer;
begin
  tcp_count := 0; udp_count := 0;
  lvPorts.Items.BeginUpdate;
  lvPorts.Clear;
  try
    TableSize := 0;
    if GetExtendedTcpTable(nil, @TableSize, False, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0) <> ERROR_INSUFFICIENT_BUFFER then
      Exit;

    GetMem(FExtendedTcpTable, TableSize);
    try
      if GetExtendedTcpTable(FExtendedTcpTable, @TableSize, TRUE, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0) = NO_ERROR then
        for i := 0 to FExtendedTcpTable.dwNumEntries - 1 do
          if FExtendedTcpTable.Table[i].dwOwningPid = pid then
          begin
            Inc(tcp_count);
            with lvPorts.Items.Add do
            begin
              Caption :=  IntToStr(ntohs(FExtendedTcpTable.Table[i].dwLocalPort));
              SubItems.Add(IntToStr(ntohs(FExtendedTcpTable.Table[i].dwRemotePort)));
              SubItems.Add('TCP');
            end;
          end;
    finally
      FreeMem(FExtendedTcpTable);
    end;

    TableSize := 0;
    if GetExtendedUdpTable(nil, @TableSize, False, AF_INET, UDP_TABLE_OWNER_PID, 0) <> ERROR_INSUFFICIENT_BUFFER then
      Exit;

    GetMem(FExtendedUdpTable, TableSize);
    try
      if GetExtendedUdpTable(FExtendedUdpTable, @TableSize, TRUE, AF_INET, UDP_TABLE_OWNER_PID, 0) = NO_ERROR then
        for i := 0 to FExtendedUdpTable.dwNumEntries - 1 do
          if FExtendedUdpTable.Table[i].dwOwningPid = pid then
          begin
            Inc(udp_count);
            with lvPorts.Items.Add do
            begin
              Caption :=  IntToStr(ntohs(FExtendedUdpTable.Table[i].dwLocalPort));
              SubItems.Add('');
              SubItems.Add('UDP');
            end;
          end;
    finally
      FreeMem(FExtendedUdpTable);
    end;
  finally
    lvPorts.Items.EndUpdate;
  end;
  UpdateCounterCaption(tcp_count, udp_count);
end;

procedure TfrmMain.lvPortsCompare(Sender: TObject; Item1, Item2: TListItem;
    Data: Integer; var Compare: Integer);
begin
  try
    Compare := StrToInt(Item1.Caption) - StrToInt(Item2.Caption);
  except
    Compare := 0;
  end;
end;

procedure TfrmMain.lvProcessesChange(Sender: TObject; Item: TListItem; Change:
    TItemChange);
begin
  if Item.SubItems.Count = 0 then
    Exit;
  UpdateCounterCaption(0, 0);
  GetPortListByPID(StrToInt(Item.SubItems[0]));
end;

procedure TfrmMain.UpdateCounterCaption(const tcp, udp: Integer);
begin
  pnlCount.Caption := Format(Counter_Caption, [tcp, udp]);
end;

end.
