# Archible

> Arch install script inspired by [crucible](https://github.com/typecraft-dev/crucible).

A simple personal install script for my Arch Linux PCs and laptops, created for whenever my OCD of reinstalling Arch every 6 months kicks in.

> [!INFO] Back Story
> When I switched to Arch from Pop!_OS, I heard a lot of people saying "\_Yeah, Arch is really unstable!_"
>
> At that time, with my limited knowledge (I was still trying to figure things out), I asked [ChatGPT](https://chat.openai.com) to basically write an install script.
>
> > It was the worst thing ever!
>
> It was not optimized... What I'm trying to say is that I **lacked** the fundamental knowledge of Bash. Hence, I didn't even think of or consider using arrays to store packages, for example.
> ChatGPT simply wrote a function that could take $x$ number of arguments (i.e., the package names) and then install them.
>
> The install script was a single file that was over 920 lines of code.
>
> > [!SUCCESS] The Revelation
> > The "_revelation_" came when this [video](https://www.youtube.com/watch?v=62mygqukbYk) by Typecraft appeared in my YouTube feed.
> >
> > This is when I realized that things shouldn't have been that complicated, and I had the eureka moment of "_I need to use arrays!_"
> >
> > Therefore, I actually went over Bash's basics again and here I am with my version of his install script!

---

## Requirements

- Vanilla Arch or any Arch-based distribution
  - If using an Arch-based distribution like [EndeavourOS](https://endeavouros.com/)
    - Select the '_No Desktop Environment_' option
- Git
- Another computer/laptop (optional)

## Usage

1. Clone this repository using the `git` command:

```bash
# clone the repository inside the home directory
git clone https://github.com/Sunhaloo/archible.git
```

2. Run the `main.sh` script found inside the `archible` directory:

```bash
# change directory to cloned repository and run personal install script
cd archible && ./main.sh
```

> [!SUCCESS]
> You should now see the script running!
>
> Go ahead and follow the prompts so that all the packages and configurations can be installed.

> [!WARNING] Archible Limitation - GitHub Setup
> This is the main/current **limitation** of this install script. Near the end, before the '_reboot_' prompt is displayed, you'll have an option to **generate** an _SSH key_ for GitHub. It will ask if you currently have a desktop environment and would like to proceed with the Git setup/configuration.
>
> But we do **not** have Hyprland set up yet, as we still need to reboot the computer!
>
> > Therefore, after rebooting, if you want to quickly set up and generate an SSH key for GitHub... you'll have to run the install script **again**!
>
> > [!TIP] Possible Solution
> > If you have another laptop with you, before you start running 'archible', try to [SSH](https://en.wikipedia.org/wiki/Secure_Shell) into the computer with another device so that you can "_remotely_" run the install script.
> >
> > This way, you can agree to the Git/GitHub configuration prompt (hopefully the other device has a desktop environment)!
> >
> > You'll just need to open up [Github][https://github.com/] and simply paste that SSH key there. When you reboot, you should be ready to use "_my_" computer!

