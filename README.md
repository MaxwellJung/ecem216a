# Fall 2024 ECE M216A - Design of VLSI Circuits and Systems
# Final Project: Hardware Realization of Multi-Program Placement (Rectangle Filling)

## Build Instructions
1. Clone this repository
    ```console
    git clone https://github.com/MaxwellJung/ecem216a.git
    ```
2. Change working directory into cloned repo (rename `ecem216a` if you want)
    ```console
    cd ecem216a
    ```
3. Source ECE M216A tool-setup
    ```console
    tcsh
    ```
    ```console
    source {path/to/ece-m216a-tool-setup}
    ```
4. Synthesize Project  
    ```console
    make
    ```
    This will create a `build/` directory for the synthesis outputs.  
    `build/report` contains design reports for power, area, timing, etc.  
    `build/synth` contains the .vg and .sdf files.
5. Open Modelsim Project for gate-level simulation
    ```console
    vsim gate-level.mpf &
    ```

## Pulling changes
To pull the latest version of main branch,  
1. Switch to main branch
    ```console
    git checkout main
    ```
2. Pull latest changes
    ```console
    git pull
    ```

## Making changes
Create new branch based on main branch
1. Start from the latest main branch
    ```console
    git checkout main && git pull
    ```
2. Create and switch to new branch (replace `{your-branch-name}` with whatever)
    ```console
    git checkout -b {your-branch-name}
    ```
3. Modify files
4. Commmit changes
    ```console
    git add .
    git commit -m "summary of changes"
    ```
5. Push changes to GitHub
    ```console
    git push -u origin {your-branch-name}
    ```
6. (Optional) Go to GitHub and submit pull request to merge your branch to main branch
