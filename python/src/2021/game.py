"""Dummy app to spawn buttons."""

import random
import tkinter as tk


def main() -> None:
    """App Main loop."""
    root = tk.Tk()
    str_var = tk.StringVar(value="Are you dump?")
    label = tk.Label(root, textvariable=str_var)
    label.pack()
    btn_yes = tk.Button(root, text="Yes")
    btn_yes.config(command=lambda: str_var.set("I knew it! :)"))
    btn_yes.pack(side="left")
    no_frame = tk.Frame(root, height=100, width=100)
    no_frame.pack(side="right")
    btn_no = tk.Button(no_frame, text="No")
    btn_no.config(command=lambda: respawn_button(no_frame, btn_no))
    btn_no.pack()
    root.mainloop()


def respawn_button(master: tk.Frame, prev_btn: tk.Button) -> None:
    """Destroy and create another button recursively."""
    prev_btn.destroy()
    prev_btn = tk.Button(master, text="No")
    prev_btn.config(command=lambda: respawn_button(master, prev_btn))
    prev_btn.place(x=random.randint(1, 30), y=random.randint(1, 30))  # noqa: S311


if __name__ == "__main__":
    main()
