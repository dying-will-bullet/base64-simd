#!/bin/python3

import random
import base64
import string

"""
Generate Benchmark source data
"""


def generate_random_string(length: int) -> str:
    letters_and_digits = string.ascii_letters + string.digits
    random_string = "".join(random.choice(letters_and_digits) for _ in range(length))
    return random_string


def generate_encode_source_data() -> None:
    with open("./testdata/encode-test-data", "w") as f:
        for i in range(1, 1001):
            for _ in range(10):
                f.write(generate_random_string(i))
                f.write("\n")


def generate_decode_source_data() -> None:
    with open("./testdata/decode-test-data", "wb") as f:
        for i in range(1, 1001):
            for _ in range(10):
                f.write(base64.b64encode(generate_random_string(i).encode()))
                f.write(b"\n")


if __name__ == "__main__":
    generate_encode_source_data()
    generate_decode_source_data()
