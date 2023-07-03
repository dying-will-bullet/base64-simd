#!/bin/python3

import random
import string


def generate_random_string(length: int) -> str:
    letters_and_digits = string.ascii_letters + string.digits
    random_string = "".join(random.choice(letters_and_digits) for _ in range(length))
    return random_string


if __name__ == "__main__":
    with open("./data", "w") as f:
        for i in range(1, 1000):
            for _ in range(10):
                f.write(generate_random_string(i))
                f.write("\n")
