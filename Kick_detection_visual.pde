// BEHAVIOUR
// when playing sound both main out A and virual out B should display some sound output. This virtual out B is send straight to the mic output which this code will use for beat detection.


// SETUP:
// 1. windows > soundsettings > output: VoiceMeeter Input
//                            > input: VoiceMeeter Output
//
// 2. Voicemeeter > Hardware Input 1, 2 = OFF
//                > Hardware Output 1 = desired sound device
//                > Hardware Output 2 = OFF

// Importing necessary libraries from the Minim audio library
import ddf.minim.*;
import ddf.minim.analysis.*;

// Global variables for audio input, FFT analysis, and visualization
Minim minim;
AudioInput in;
FFT fft;
int graphWidth;
float[] energyGraph;
int graphIndex = 0;

// Parameters for kick detection
float thresholdMultiplier = 0.95f;
int energyHistorySize = 1000;
float maxEnergyPeak = 0;
float thresholdAdaptiveness = 0.05f;
float kickDetectionLowFreq = 40; // Lower frequency range for kick detection
float kickDetectionHighFreq = 90; // Higher frequency range for kick detection
float minEnergyLevel = 130; // Minimum energy level for adaptive threshold adjustment

// BPM estimation parameters
float bpmDecayRate = 0.99f;
int bpmWindowSize = 8;
float bpmLowerLimit = 30;
long kickDetectionDebounceTime = 200;
long noKickDecayTime = 2000;
float minExpectedBPM = 120;
float maxExpectedBPM = 170;

// Additional parameters for managing BPM and energy detection
float estimatedBPM = 0;
ArrayList<Float> recentBPMValues = new ArrayList<Float>();
int recentBPMSize = 20;
ArrayList<Float> energyHistory = new ArrayList<Float>();
float adaptiveThreshold = 1;
ArrayList<Long> kickTimes = new ArrayList<Long>();
float current_bpm = 0;
long lastKickDetectionTime = 0;
boolean isKickPresent = false;

void setup() {
  size(800, 400); // Setting up the window size for the visualization
  minim = new Minim(this); // Initializing the Minim library
  in = minim.getLineIn(Minim.STEREO, 2048); // Getting line-in audio input
  fft = new FFT(in.bufferSize(), in.sampleRate()); // Initializing the FFT object
  
  graphWidth = width; // Setting the graph width to the width of the window
  energyGraph = new float[graphWidth]; // Initializing the energy graph array
  current_bpm = bpmLowerLimit; // Initializing BPM to the lower limit
  
  // Initializing variables for kick detection and BPM calculation
  isKickPresent = false;              
  adaptiveThreshold = minEnergyLevel; 
  estimatedBPM = minExpectedBPM;     
}

void draw() {
  background(0); // Clearing the window with a black background
  fft.forward(in.mix); // Performing FFT analysis on the mixed audio input

  // Analyzing low frequency energy for kick detection
  float lowFreqEnergy = fft.calcAvg(kickDetectionLowFreq, kickDetectionHighFreq);
  updateEnergyHistory(lowFreqEnergy); // Updating the energy history for adaptive threshold calculation
  if (lowFreqEnergy > minEnergyLevel) {
    adaptiveThreshold = calculateAdaptiveThreshold(lowFreqEnergy);
  }

  // Updating the energy graph with the new energy value
  energyGraph[graphIndex] = lowFreqEnergy;
  graphIndex = (graphIndex + 1) % graphWidth;

  // Detecting kicks based on the adaptive threshold
  boolean kickDetected = lowFreqEnergy > adaptiveThreshold;
  if (kickDetected) {
    isKickPresent = true;
    maxEnergyPeak = max(maxEnergyPeak, lowFreqEnergy);
    // Debouncing kick detection
    if (kickTimes.isEmpty() || millis() - kickTimes.get(kickTimes.size() - 1) > kickDetectionDebounceTime) {
      kickTimes.add(Long.valueOf(millis()));
      calculateBPM(); // Calculating BPM on kick detection
      lastKickDetectionTime = millis();
    }
  } else {
    // Handling the absence of kicks
    if (millis() - lastKickDetectionTime > noKickDecayTime) {
      isKickPresent = false;
    }
  }

  // Applying BPM decay when no kicks are detected for a while
  if (!isKickPresent && millis() - lastKickDetectionTime > noKickDecayTime) {
    current_bpm *= bpmDecayRate;
    if (current_bpm < bpmLowerLimit) {
      current_bpm = bpmLowerLimit;
      adaptiveThreshold = minEnergyLevel; // Resetting the adaptive threshold
    }
  } else if (isKickPresent) {
    // Adjusting BPM based on recent kick detection
    if(current_bpm + 20 < estimatedBPM && estimatedBPM > bpmLowerLimit) {
      current_bpm = estimatedBPM;
    }
  }

  // Ensuring BPM stays within expected limits
  current_bpm = constrain(current_bpm, bpmLowerLimit, maxExpectedBPM);

  // Updating the BPM display if a kick is present
  if (isKickPresent) {
    updateBPM(current_bpm);
  }

  // Drawing the visualization components
  drawGraphAndThreshold();
  drawMinEnergyLevel();

  // Displaying current and estimated BPM values
  fill(255);
  text("Current BPM: " + nf(current_bpm, 0, 2), 10, 20);
  text("Estimated BPM: " + nf(estimatedBPM, 0, 2), 10, 40);
}

// Updates the energy history with the latest low frequency energy value
void updateEnergyHistory(float energy) {
  energyHistory.add(energy); // Adding the current energy to the history
  if(energyHistory.size() > energyHistorySize) {
    energyHistory.remove(0); // Ensuring the energy history size does not exceed the specified limit
  }
}

// Calculates an adaptive threshold based on the recent energy history
float calculateAdaptiveThreshold(float currentEnergy) {
  float sum = 0;
  int count = 0; // Count of energies above the minimum energy level
  for (Float e : energyHistory) {
    if (e > minEnergyLevel) {
      sum += e;
      count++;
    }
  }
  // Calculating the current average energy from values above the minimum energy level
  float currentAverageEnergy = (count > 0) ? sum / count : minEnergyLevel;
  // Calculating the current threshold based on the maximum energy peak and the average energy
  float currentThreshold = max(minEnergyLevel, min(maxEnergyPeak * thresholdMultiplier, currentAverageEnergy * thresholdMultiplier));
  // Adjusting the adaptive threshold using the adaptiveness parameter
  adaptiveThreshold = (adaptiveThreshold * (1 - thresholdAdaptiveness)) + (currentThreshold * thresholdAdaptiveness);
  return adaptiveThreshold;
}

// Draws the graph of energy over time and the adaptive threshold line
void drawGraphAndThreshold() {
  stroke(255); // Setting the stroke color to white for the energy graph
  for(int i = 0; i < graphWidth - 1; i++) {
    int idx = (graphIndex + i) % graphWidth;
    // Drawing lines between consecutive energy values to create a continuous graph
    line(i, height - energyGraph[idx] * 2, i + 1, height - energyGraph[(idx + 1) % graphWidth] * 2);
  }
  
  stroke(255, 0, 0); // Setting the stroke color to red for the adaptive threshold
  // Drawing a horizontal line representing the adaptive threshold
  line(0, height - adaptiveThreshold * 2, width, height - adaptiveThreshold * 2);
}

// Draws a line representing the minimum energy level required for kick detection
void drawMinEnergyLevel() {
  stroke(0, 255, 0); // Setting the stroke color to green for the minimum energy level
  // Drawing a horizontal line representing the minimum energy level
  line(0, height - minEnergyLevel * 2, width, height - minEnergyLevel * 2);
}

// Calculates the BPM based on the time intervals between detected kicks
void calculateBPM() {
  if(kickTimes.size() < 2) return; // Requires at least two kicks to calculate BPM

  // Determining the window size for BPM calculation
  int windowSize = min(bpmWindowSize, kickTimes.size());
  long totalTime = 0;
  // Summing the time intervals between consecutive kicks within the window
  for(int i = kickTimes.size() - 1; i > kickTimes.size() - windowSize; i--) {
    totalTime += (kickTimes.get(i) - kickTimes.get(i - 1));
  }
  // Calculating the average interval and converting it to BPM
  float avgInterval = totalTime / (float)(windowSize - 1);
  float calculatedBPM = 60000 / avgInterval;

  // Setting the current and estimated BPM if the calculated BPM is within expected limits
  if (calculatedBPM >= minExpectedBPM && calculatedBPM <= maxExpectedBPM) {
    current_bpm = calculatedBPM;
    estimatedBPM = current_bpm;
  }
}

// Updates the estimated BPM based on recent BPM values
void calculateEstimatedBPM() {
  if (recentBPMValues.size() >= recentBPMSize) {
    float sum = 0;
    for (Float bpmValue : recentBPMValues) {
      sum += bpmValue; // Summing the stored BPM values
    }
    // Calculating the average BPM and rounding to the nearest whole number
    estimatedBPM = round(sum / recentBPMValues.size());
  }
}

// Updates the list of recent BPM values with a new BPM if a kick is present
void updateBPM(float newBPM) {
  if (isKickPresent && newBPM >= minExpectedBPM && newBPM <= maxExpectedBPM) {
    if (recentBPMValues.size() >= recentBPMSize) {
      recentBPMValues.remove(0); // Ensuring the list size does not exceed the specified limit
    }
    recentBPMValues.add(newBPM); // Adding the new BPM to the list
    calculateEstimatedBPM(); // Updating the estimated BPM based on recent values
  }
}

// Cleans up resources when the program is stopped
void stop() {
  in.close(); // Closing the audio input
  minim.stop(); // Stopping the Minim audio library
  super.stop(); // Calling the stop method of the parent class
}
