uses System, System.IO, Microsoft.Win32;
{$apptype windows}


//ToDo: Сделать папку и файл невидимыми. 
//ToDo: Сделать проверку на один и тот же файл,если имя файла совпадают,то увелечить значение,если нет,то записать имя файла и версию. - сделал
//ToDo: Сделать функцию получающая номер версии файла. - сделал
//ToDo: Сделать графический показ изменений(другое приложение)
//ToDO: Исправить ошибку доступа к файлу PGit.GitIni
//ToDo: Не работает если больше одного файла - исправил
//ToDo: Исправить счетчик версий(после 1.8 или 1.999) - Сделал просто счетчик целых чисел
//ToDo: Сделать окно невидимым. - сделал 
//ToDo: Сделать графический обзор изминений(другое приложение)
//ToDo: Сделать аргумент с приявзякой к файлу(path:*Путь к файлу),и в IDE тоже
//ToDo: Сделать "help" если запуск без аргументов.
//ToDo: Изменить реестр так,что бы запсук был из папки,где установлен Паскаль


const
  fnconfig = 'PGit.GitIni';
  GDirectory = 'PGitVersion';
  GExeconfig = 'GitExeConfig.GitConfig';

function string.GetString(oi, ni: integer): string;
begin
  for var i := oi to ni do 
    result += self[i];
end;

function GetVersion(key, fname: string): string;
begin
  result := ReadAllLines(fname).Where(s -> key in s).JoinToString;
  result := result.GetString(result.IndexOf('=') + 2, result.Length);
end;

function GetKey(key, fname: string) := ReadAllLines(fname).Count(s -> key in s) > 0;

procedure SetVersion(Name, Value, fname: string) := System.IO.File.AppendAllText(fname, $'{Name}={Value}' + NewLine);

procedure ReVersion(CName, NValue, fname: string);
begin
  if &File.Exists(fname)
  then begin
    var a := ReadAllLines(fname);
    var j: integer;
    for var i := 0 to a.Length - 1 do 
      if Cname in a[i]
      then begin
        j := i;
        break;
      end;
    a[j] := $'{Cname}={NValue}';
    if GetKey(Cname, fname)
      then WriteAllLines(fname, a)
    else SetVersion(Cname, Nvalue, fname);
  end
  else SetVersion(Cname, Nvalue, fname);
end;

procedure TextOut(c: ConsoleColor; s: string);
begin
  var fc := Console.ForegroundColor;
  Console.ForegroundColor := c;
  writeln(s);
  Console.ForegroundColor := fc;
end;

procedure SaveFile(name, path, ras: string);
begin
  path += '\';
  var v := 1;
  var f := path + fnconfig;//Путь к файлу с версиями
  var d := path + GDirectory;//Путь к папке с версиями файлов
  var fname := name + ras;
  
  if &File.Exists(f)
  then begin
    if GetKey(fname, f)
      then v := GetVersion(fname, f).ToInteger
    else ReVersion(fname, v.ToString, f);
  end;  
  
  var di := Directory.CreateDirectory(d);
  di.Attributes := FileAttributes.Hidden; //FileAttributes.Directory and 
  
  var upfname := $'{path}{GDirectory}\{name}_{v}{ras}';
  var oldfname := $'{path}{name}{ras}';
  
  v += 1;
  ReVersion(fname, v.ToString, f);
  //&File.SetAttributes(f, FileAttributes.Hidden);
  &File.Copy(oldfname, upfname);
end;

begin
  if not &File.Exists(GExeconfig)
  then begin
    try
      var GitNewkey := Registry.ClassesRoot;
      var GitKey := GitNewkey.CreateSubKey('PABCNetGit', true);
      var CrShell := GitKey.CreateSubKey('Shell');
      CrShell.SetValue('', 'ToGit');
      var CrToGit := CrShell.CreateSubKey('ToGit', true);
      CrToGit.SetValue('','Сохранить в Git');
      var CrComm := CrToGit.CreateSubKey('Command');
      CrComm.SetValue('', '"E:\PascalABC.NET\PABCNetGit.exe" "%1"');
      GitNewkey.Close;
    except
      on e: Exception do begin
        TextOut(ConsoleColor.Red, e.ToString);
        sleep(15000);
      end;
    end;
  end;
  if ParamCount = 0
  then begin
    TextOut(ConsoleColor.Red, 'Параметры не переданы!');
    sleep(5000);
  end
  else begin
    var fname := ParamStr(1);
    var path := System.IO.Path.GetDirectoryName(fname);
    var ras := fname.GetString(fname.LastIndexOf('.') + 1, fname.Length);
    fname := fname.GetString(fname.LastIndexOf('\') + 2, fname.LastIndexOf('.'));
    try
      SaveFile(fname, path, ras);
    except
      on e: Exception do begin
        TextOut(ConsoleColor.Red, e.ToString);
        sleep(15000);
      end;
    end;
  end;
end.
