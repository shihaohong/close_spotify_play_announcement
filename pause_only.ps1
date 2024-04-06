# Check if Spotify is running
$processName = 'Spotify'
$spotifyProcess = Get-Process -Name $processName
if ($spotifyProcess) {
    $spotifyWindowTitle = (Get-Process -Name $processName).MainWindowTitle


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
    }
    else {
        Write-Host "Music is not playing"
    }
}
else {
    Write-Host "Spotify is not running."
}
