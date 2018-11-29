from setuptools import find_packages
from setuptools import setup

REQUIRED_PACKAGES = []

setup(
    name="shakespeare-rnn",
    version="0.1.0-SNAPSHOT",
    install_requires=REQUIRED_PACKAGES,
    packages=find_packages(),
    include_package_data=True,
    description="A Recurrent Neural Network used to generate a poem in the "
                "style of Shakespeare."
)
