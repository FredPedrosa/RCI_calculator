# Reliable Change Index (RCI) Estimator Shiny Apps

This repository contains the code for two Shiny web applications (one in English, one in Portuguese) designed to calculate the Reliable Change Index (RCI) as described by Jacobson & Truax (1991). These apps help researchers and clinicians determine if the change observed in an individual's score between two time points (T1 and T2) is statistically reliable or likely due to measurement error.

The applications also generate a plot visualizing Reliable Recovery categories using the `rciplot` package.

## Features

*   **RCI Calculation:** Computes the RCI score for each participant based on their T1 and T2 scores and the provided measure reliability.
*   **Interpretation:** Classifies the change for each participant as:
    *   **English App:** Reliable Positive Change (RPC), Reliable Negative Change (RNC), or No Reliable Change (NRC).
    *   **Portuguese App:** Mudança Positiva Confiável (MPC), Mudança Negativa Confiável (MNC), or Ausência de Mudança Confiável (AMC).
*   **Reliable Recovery Plot:** Generates a scatter plot visualizing T1 vs. T2 scores, categorizing participants into recovery statuses (e.g., Recovered, Improved, Unchanged, Deteriorated) based on the RCI, a recovery cutoff point, and whether higher scores indicate improvement. Uses the `rciplot` package.
*   **Dynamic Input:** Allows users to specify the number of participants and dynamically generates input fields for each participant's T1 and T2 scores.
*   **Cutoff Flexibility:** Offers two options for defining the recovery cutoff point used in the plot:
    1.  **Calculate from sample:** Calculates the cutoff as `Mean(T1) + 2 * SD(T1)` based on the provided sample's baseline data.
    2.  **Specify cutoff value:** Allows the user to input a predefined cutoff score.
*   **Directionality:** Includes an option (`Higher value is better`) to specify whether improvement on the measure is indicated by higher or lower scores, which affects the interpretation in the `rciplot`.
*   **Bilingual:** Provides two separate apps with interfaces and interpretations in English and Portuguese.

## Applications Overview

### 1. English Version (`rci_app_en`)

*   **Description:** The primary application with an English user interface and output interpretation (RPC, RNC, NRC).
*   **Code:** `RCI_app.R` (or similar).
*   **Live App Link (Example):** [https://fredpedrosa.shinyapps.io/rci_app/](https://fredpedrosa.shinyapps.io/rci_app/) 

### 2. Portuguese Version (`rci_app_pt`)

*   **Description:** A version of the application with a Portuguese user interface and output interpretation (MPC, MNC, AMC).
*   **Code:** Assumed to be in `RCI_pr_app.R` (or similar).
*   **Live App Link (Example):** [https://fredpedrosa.shinyapps.io/JT_pt/](https://fredpedrosa.shinyapps.io/JT_pt/) 

## How it Works

The core calculation follows the standard RCI formula:

1.  **Standard Error of Measurement (SEm):** `SEm = SD(T1) * sqrt(1 - reliability)`
2.  **Standard Error of Difference (SEdiff):** `SEdiff = sqrt(2 * SEm^2)`
3.  **Reliable Change Index (RCI):** `RCI = (Score_T2 - Score_T1) / SEdiff`

Where `SD(T1)` is the standard deviation of the scores at baseline (T1) from the provided sample, and `reliability` is the reliability coefficient (e.g., Cronbach's alpha, test-retest) of the measure.

A change is typically considered reliable if the absolute RCI value exceeds 1.96 (corresponding to p < 0.05, two-tailed).

The plot utilizes the `rciplot` package, which uses the calculated RCI score and the chosen recovery cutoff point to classify individuals.

## Usage

### Running Locally

1.  **Prerequisites:** Ensure you have R and RStudio (recommended) installed.
2.  **Install Packages:** Open R/RStudio and install the required packages if you haven't already:
    ```R
    install.packages(c("shiny", "dplyr", "rciplot", "ggplot2"))
    ```
3.  **Clone Repository:** Clone this repository to your local machine.
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```
4.  **Run App:**
    *   Navigate to the directory containing the app file (e.g., `RCI_app.R` or `RCI_pt_app.R`) within RStudio or your R console.
    *   Use the `runApp()` function:
        ```R
        # To run the English app 
        shiny::runApp("RCI_app.R") 
        
        # To run the Portuguese app (assuming it's named app_pt.R)
        shiny::runApp("RCI_pt_app.R")
        ```

### Using the Deployed Apps

Access the live applications via the links provided in the [Applications Overview](#applications-overview) section (once deployed).

## Input Requirements

Users need to provide the following information in the sidebar panel:

1.  **Number of Participants:** The total number of individuals in the sample.
2.  **Measured Variable Name:** A descriptive name for the variable being measured (used for context).
3.  **Variable Reliability:** The reliability coefficient of the measure (e.g., 0.90).
4.  **Higher value is better:** Checkbox indicating the direction of improvement.
5.  **Cutoff Option:** Select whether to calculate the recovery cutoff from the sample T1 data or specify a value manually.
6.  **Specified Cutoff Value:** (Only if "Specify cutoff value" is chosen) The predefined score for recovery.
7.  **Participant Scores:** Enter the score for each participant at T1 and T2 in the dynamically generated fields.

## Output Interpretation

*   **Table:** Displays the T1 score, T2 score, calculated RCI, and the interpretation (RPC/MPC, RNC/MNC, or NRC/AMC) for each participant.
*   **Plot:** Visualizes T1 vs. T2 scores. Points are colored and shaped according to their Reliable Recovery status (Recovered, Improved, Unchanged, Deteriorated), considering the RCI, the recovery cutoff, and whether higher scores are better. Refer to the `rciplot` documentation for detailed category definitions.

## Technology Stack

*   R
*   Shiny
*   dplyr
*   rciplot
*   ggplot2

## How to Cite

### English App
Pedrosa, F. G. (2025). *Reliable Change Index estimator*. [Software]. https://fredpedrosa.shinyapps.io/rci_app/ *(Update year and URL)*

### Portuguese App
Pedrosa, F. G. (2025). *Estimador do Índice de Mudança Confiável*. [Software]. https://fredpedrosa.shinyapps.io/JT_pt/ *(Update year and URL)*

### Plot Package
Hagspiel, M. (2023). *rciplot: Plot Jacobson-Truax Reliable Change Indices*. R package version 0.1.1, <https://CRAN.R-project.org/package=rciplot>.

## Author

*   **Prof. Dr. Frederico G. Pedrosa**
*   fredericopedrosa@ufmg.br

## License

This project is licensed under a modified version of the GNU General Public License v3.0.  
Commercial use is not permitted without explicit written permission from the author.
