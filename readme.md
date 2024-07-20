# Blaize 3 + botched BPM detection 
This fork introduces a new BPM detection algorithm, adding kick detection integration and dynamic preset speed control. The application's visual effects now adjust in real-time based on the detected BPM, making it more responsive to music.

This code will now analyze the energy content of a specific frequency, particularly the frequency of a kick drum. By monitoring the energy at this frequency and comparing it to a predefined dynamic threshold, the code counts occurrences where the energy surpasses the threshold. This count is then used to estimate the Beats Per Minute (BPM) of the music over time. This method is particularly effective for music genres such as techno and house, where the kick drum is a prominent element. During segments of a track where the kick drum is less dominant, the estimated BPM may decrease but will quickly adjust back to the previously determined BPM when the kick drum reappears.

The code also includes modifications to improve the communication with an accompanying app. These modifications include disabling certain buttons to streamline the user interface and adjusting the speed slider to function as a multiplier, allowing for fine-tuning of the animation speeds. 

#It is botched but works
While the BPM estimation may not always be perfectly synchronized with the beat, the ability to slow down animations during transitions or build-ups significantly enhances the overall experience. This approach ensures smoother and more dynamic visual transitions in sync with the music's tempo variations.

# How to setup
To set up the application, download Voicemeeter or similar software for audio routing:

Windows Sound Settings:
- Playback: Default should be Voicemeeter
- Recording: Default should be Voicemeeter Output
  
Voicemeeter Configuration:
- No hardware inputs (mic not needed).
- Virtual Input: Input from the PC.
- Hardware Output: Set to the desired device.

The code utilizes the Minim library to handle virtual input for audio analysis. Once the setup is complete, you can run blaize_v3.pde as usual to see the BPM estimation and animation adjustments in action.



# Summary of major changes 
Kick Detection Integration
- Added the Minim library for audio processing.
- Implemented kick detection with way to many parameters.
- Developed methods to detect kick events and calculate BPM.

BPM and Preset Speed Integration
- Linked BPM detection with preset speed control for dynamic adjustment.
- Introduced variables to manage preset speed limits and multipliers.

Button Changes
- Updated color button initialization with new colors.
- Adjusted initial values for buttons and sliders, such that the App cannot disrubt the BPM detection.

Password Handling
- Changed the realPass variable to a single space, to speed up startup process.






# Blaize 3
Software to turn your projector into a safe disco laser \
[Blaize 3 Demo Video](https://www.youtube.com/watch?v=ziG_0-8F9Vg) | [Blaize 3 HowTo Video](https://www.youtube.com/watch?v=TjnYWlusAS8)

<img src="https://user-images.githubusercontent.com/66431086/210280032-069e732e-a1dc-47e4-9878-f0d07ae74a07.jpg" alt="Blaize A" width="33%"/><img src="https://user-images.githubusercontent.com/66431086/210280030-75ffe951-4d7d-4b78-b2eb-d3e1925f3cbf.jpg" alt="Blaize B" width="33%"/><img src="https://user-images.githubusercontent.com/66431086/210280031-72a5341b-5e95-4a7d-ae65-40a8c9a79776.jpg" alt="Blaize C" width="33%"/>
</br>
</br>

# Releases
You can find prebuilt binaries for each release on the [release page](https://github.com/bodgedbutworks/Blaize_V3/releases).
> **Note for mac users**: \
> If you download the prebuilt releases, they are considered suspicious and receive a quarantine flag. This results in errors such as `The application is corrupted and should be removed` and the application not starting.
> This can be prevented either by installing [Processing 3](https://processing.org/download/) yourself and running the program from source OR (quicker) by removing the quarantine flag from the app.
> To remove the flag open a terminal window (Spotlight search [CMD+Space], type "Term...") and execute the following commands: \
> __Navigate to where Blaize was downloaded. You can partially type the directory names (e.g. "Blai...") and press TAB multiple times to autocomplete:__ \
> ```cd ~/Downloads/Blaize_v3.0.1_macos-x86_64``` \
> __Remove quarantine flag:__ \
> ```sudo xattr -d -r com.apple.quarantine Blaize_V3.app```
</br>

# Users
You'll need a standard projector and a fog machine. Head over to [Blaize 3 Demo](https://www.youtube.com/watch?v=ziG_0-8F9Vg) to see what Blaize can do and to [Blaize 3 HowTo](https://www.youtube.com/watch?v=TjnYWlusAS8) to learn how to download and use it. Have fun and feel free to share some pictures/videos when it's working! \
Pro tip: Set the **contrast** and **saturation** of your projector to maximum for even more vivid colors.

### Android Remote Control App
I've written an app to remote control both Blaize and my other (video mapping) software [VidMap](https://github.com/bodgedbutworks/vidmap). \
Download the APK to your Android phone. You'll have to enable installing apps from untrusted sources (luckily, I am a trusted source ;). \
Your phone must be in the same network as the PC(s) running Blaize (or VidMap). On the rightmost tab, enter the IP(s) of the Blaize/VidMap host PC(s) (yes, you can remote control both at the same time from one phone! Innovation!). You can hold-and-drag the numbers or use the +/- buttons. Press the `Blaize` or `VidMap` button on the left to connect. As soon as those turn green, you're good to go! Have fun and feel free to contact me if the app won't start or connect or if you have questions concerning the usage.

<img src="https://user-images.githubusercontent.com/66431086/210279531-0c18f649-c391-40ea-b910-d6cf9cd54648.jpg" alt="Blaize & VidMap Remote Control App Screenshot 1" width="25%"/><img src="https://user-images.githubusercontent.com/66431086/210279535-d054b843-fd0c-4b2c-ad36-218e5563f1ee.jpg" alt="Blaize & VidMap Remote Control App Screenshot 2" width="25%"/><img src="https://user-images.githubusercontent.com/66431086/210279537-f17c323f-a2f2-4a2f-a9eb-9510a1464f5f.jpg" alt="Blaize & VidMap Remote Control App Screenshot 3" width="25%"/><img src="https://user-images.githubusercontent.com/66431086/210279538-2130cb8f-bba5-4987-9af4-ac942f533243.jpg" alt="Blaize & VidMap Remote Control App Screenshot 4" width="25%"/>
</br>
</br>

# Developers
Feel free to integrate your own ideas or even re-structure the code. It's not the cleanest, as it started as one of my first Java/Processing projects.
If you have any questions or requests, you can contact me via email (bodgedbutworks<(at)>aerotrax<(dot)>de) or on Instagram (@bodgedbutworks).

You will need Processing 3 to run the code: https://processing.org/download
If you're missing libraries, you can simply install them using Processing's built-in library manager.
<br>
<br>

### Why isn't the Android remote control app open source?
...because it's a pile of ravioli code from my early beginnings and I don't want to hurt your eyes.
If you like the app AND you REALLY want to spend time cleaning up smelly code, then feel free to message me an I can commit <del>a crime</del> the app's source code.
