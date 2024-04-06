

# Check if Spotify is running
$processName = 'Spotify'
$spotifyProcess = Get-Process -Name $processName
$mp3File = 'C:\Users\Shi Hao\PowerShellScripts\bing_bong.mp3'
# Get Spotify window title
$spotifyWindowTitle = (Get-Process -Name $processName).MainWindowTitle

if ($spotifyProcess) {
    # Heuristic -- If Spotify Premium, window title is "Spotify Premium" when nothing is playing
    Write-Host $spotifyWindowTitle

    if (-not($spotifyWindowTitle -ilike "*Spotify*")) {
        # Spotify is running, send play/pause media key
        Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class SpotifyControl {
        [DllImport("user32.dll", SetLastError=true)]
        public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

        public const byte VK_MEDIA_PLAY_PAUSE = 0xB3; // Media Play/Pause key

        public static void SendPlayPause() {
            keybd_event(VK_MEDIA_PLAY_PAUSE, 0, 0x0000, UIntPtr.Zero);
            keybd_event(VK_MEDIA_PLAY_PAUSE, 0, 0x0002, UIntPtr.Zero);
        }
    }
"@

        [SpotifyControl]::SendPlayPause()

        # Check if the MP3 file exists
        if (Test-Path $mp3File) {
            Add-Type -AssemblyName presentationCore
            $mediaPlayer = New-Object system.windows.media.mediaplayer
            $mediaPlayer.open($mp3File)
            $mediaPlayer.Play()
        }
        else {
            Write-Host "The specified MP3 file does not exist."
        }    
    }
    else {
        Write-Host "Music is not playing"
    }
}
else {
    Write-Host "Spotify is not running."
}
