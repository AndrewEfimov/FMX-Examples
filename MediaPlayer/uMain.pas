unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Media, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, System.ImageList, FMX.ImgList;

type
  TFormMain = class(TForm)
    TabControl1: TTabControl;
    tiPlay: TTabItem;
    tiList: TTabItem;
    MediaPlayer1: TMediaPlayer;
    Layout1: TLayout;
    sbPrevTrack: TSpeedButton;
    sbPlayOrPause: TSpeedButton;
    sbNextTrack: TSpeedButton;
    Layout2: TLayout;
    TrackBar1: TTrackBar;
    Timer1: TTimer;
    ListView1: TListView;
    lbCurrentTime: TLabel;
    Layout3: TLayout;
    lbDuration: TLabel;
    lbTrackName: TLabel;
    Layout4: TLayout;
    sbLoadList: TSpeedButton;
    Layout5: TLayout;
    sbShuffle: TSpeedButton;
    ImageList1: TImageList;
    sbRepeate: TSpeedButton;
    procedure sbPlayOrPauseClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ListView1Change(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure sbPrevTrackClick(Sender: TObject);
    procedure sbNextTrackClick(Sender: TObject);
    procedure sbLoadListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FListFiles: TArray<string>;
    function SearchFiles(const AFolderPath: string): TArray<string>;
    procedure Play(const AIsNewTrack: Boolean = False);
    procedure Pause;
    procedure NextTrack(const AIsUserClick: Boolean = False);
    procedure Clear;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

uses
  System.iOUtils;

function TFormMain.SearchFiles(const AFolderPath: string): TArray<string>;
begin
  Result := TDirectory.GetFiles(AFolderPath, '*.mp3', TSearchOption.soAllDirectories);
end;

procedure TFormMain.NextTrack(const AIsUserClick: Boolean);
begin
  if ListView1.ItemIndex <> -1 then
  begin
    if sbShuffle.IsPressed then
      ListView1.ItemIndex := Random(ListView1.Items.Count)
    else
    begin
      if ListView1.ItemIndex < (ListView1.Items.Count - 1) then
        ListView1.ItemIndex := ListView1.ItemIndex + 1
      else
      begin
        if sbRepeate.IsPressed or AIsUserClick then
          ListView1.ItemIndex := (ListView1.Items.Count - 1) - ListView1.ItemIndex
        else
          Clear;
      end;
    end;

    Play(True);
  end;
end;

procedure TFormMain.Pause;
begin
  MediaPlayer1.Stop;
  Timer1.Enabled := False;
  sbPlayOrPause.ImageIndex := 2;
end;

procedure TFormMain.Play(const AIsNewTrack: Boolean);
begin
  if AIsNewTrack then
  begin
    if ListView1.ItemIndex <> -1 then
    begin
      MediaPlayer1.FileName := FListFiles[ListView1.ItemIndex];
      if MediaPlayer1.Media <> nil then
      begin
        TrackBar1.Max := MediaPlayer1.Duration;
        lbDuration.Text := MediaPlayer1.Duration.ToString;
        MediaPlayer1.CurrentTime := 100000; // Fix bug sound on Windows
      end;
    end;
  end
  else
    MediaPlayer1.CurrentTime := Round(TrackBar1.Value);

  if MediaPlayer1.Media <> nil then
  begin
    MediaPlayer1.Play;
    Timer1.Enabled := True;
    sbPlayOrPause.ImageIndex := 3;
    lbTrackName.Text := TPath.GetFileNameWithoutExtension(MediaPlayer1.FileName);
  end;
end;

procedure TFormMain.Clear;
begin
  Pause;
  MediaPlayer1.Clear;
  ListView1.ItemIndex := -1;
  TrackBar1.Value := 0;
  TrackBar1.Max := 0;
  lbDuration.Text := '00:00:00';
  lbCurrentTime.Text := '00:00:00';
  lbTrackName.Text := '';
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Randomize;
end;

procedure TFormMain.ListView1Change(Sender: TObject);
begin
  if MediaPlayer1.State = TMediaState.Playing then
    Pause;

  Play(True);
end;

procedure TFormMain.sbLoadListClick(Sender: TObject);
var
  I: Integer;
  ListViewItem: TListViewItem;
begin
  if TabControl1.ActiveTab = tiList then
  begin
    FListFiles := SearchFiles(TPath.GetSharedMusicPath);

    ListView1.Items.Clear;
    ListView1.BeginUpdate;
    try
      for I := Low(FListFiles) to High(FListFiles) do
      begin
        ListViewItem := ListView1.Items.Add;
        ListViewItem.Text := TPath.GetFileNameWithoutExtension(FListFiles[I]);
      end;
    finally
      ListView1.EndUpdate;
    end;
  end;
end;

procedure TFormMain.sbNextTrackClick(Sender: TObject);
begin
  NextTrack(True);
end;

procedure TFormMain.sbPlayOrPauseClick(Sender: TObject);
begin
  if MediaPlayer1.State = TMediaState.Playing then
    Pause
  else if MediaPlayer1.State = TMediaState.Stopped then
    Play(False);
end;

procedure TFormMain.sbPrevTrackClick(Sender: TObject);
begin
  if ListView1.ItemIndex <> -1 then
  begin
    if sbShuffle.IsPressed then
      ListView1.ItemIndex := Random(ListView1.Items.Count)
    else
    begin
      if ListView1.ItemIndex > 0 then
        ListView1.ItemIndex := ListView1.ItemIndex - 1
      else
        ListView1.ItemIndex := ListView1.Items.Count - 1;
    end;

    Play(True);
  end;
end;

procedure TFormMain.Timer1Timer(Sender: TObject);
begin
  if (MediaPlayer1.State = TMediaState.Playing) then
  begin
    TrackBar1.Tag := 1;
    TrackBar1.Value := MediaPlayer1.CurrentTime;
    TrackBar1.Tag := 0;
    lbCurrentTime.Text := MediaPlayer1.CurrentTime.ToString;
  end;

  if (MediaPlayer1.State = TMediaState.Stopped) and (MediaPlayer1.CurrentTime = MediaPlayer1.Duration) then
    NextTrack(False);
end;

procedure TFormMain.TrackBar1Change(Sender: TObject);
begin
  if TrackBar1.Tag = 0 then
    MediaPlayer1.CurrentTime := Round(TrackBar1.Value);
end;

end.
