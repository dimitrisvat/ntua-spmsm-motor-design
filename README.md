# Permanent-Magnet Synchronous Motor (PMSM)

Academic project developed at the **National Technical University of Athens (NTUA)** as part of the Electric Machine Design course.

The project covers the **analytical design, finite element analysis (FEA), and performance evaluation of a 6-pole Surface-Mounted PMSM**.

## Highlights

* Analytical winding design, MMF distribution, and harmonic analysis
* Air-gap magnetic field, Carter's coefficient, and slot leakage calculations
* 2D FEA simulation using FEMM ($d$- $q$ axis identification, alignment, cogging torque)
* Torque vs. torque angle ($T$- $\delta$) characteristic curves under nominal loading
* $d$- and $q$-axis inductance computation ($L_d$, $L_q$) and core saturation analysis
* Comprehensive parametric sweeps ($I$, $\delta$) and magnetic flux density distribution ($B_x$- $B_y$ loci)
* MTPA optimization and back-EMF voltage limitation constraints (1000 & 2000 rpm)
* Dynamic harmonic analysis (FFT) of flux linkages, back-EMF, and torque ripple

## Tools

* FEMM (Finite Element Method Magnetics)
* MATLAB
* LaTeX

## Repository

- **[`Basic functions/`](./Basic%20functions/)** — MATLAB scripts and functions for the main motor-design workflow, FEMM setup, geometry creation, transformations, torque calculation, and related calculations
- **[`Functions/`](./Functions/)** — MATLAB functions for stator and rotor geometry, winding creation, back-EMF computation, flux-density analysis, synchronous rotation, current definition, and torque analysis
- **[`Synchronous_Post.m`](./Synchronous_Post.m)** — MATLAB post-processing script for synchronous-rotation analysis
- **[`Synchronous_Post2.m`](./Synchronous_Post2.m)** — MATLAB post-processing script for synchronous-rotation analysis
- **[`ElectricMachine_Design_report_english.pdf`](./ElectricMachine_Design_report_english.pdf)** — Full English report
- **[`ElectricMachine_Design_report.pdf`](./ElectricMachine_Design_report.pdf)** — Full Greek original report
- **[`KHM_Thema_2025.pdf`](./KHM_Thema_2025.pdf)** — Course assignment
- **[`KHM_Thema_complement.pdf`](./KHM_Thema_complement.pdf)** — Supplementary course assignment material

---

**National Technical University of Athens — 2025/2026**

Dimitris V.
