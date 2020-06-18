import setuptools

import sys
if not any('pip' in x for x in sys.argv):
    sys.stderr.write("Please use pip to install py-eb-tutorial!\n")
    sys.exit(1)

setuptools.setup(
    name='py-eb-tutorial',
    version='1.0.0',
    author="Kenneth Hoste",
    author_email='kenneth.hoste@ugent.be',
    description="Python example for EasyBuild tutorial - https://easybuilders.github.io/easybuild-tutorial",
    packages=setuptools.find_packages(),
    entry_points={'console_scripts': ['py-eb-tutorial=eb_tutorial:main']},
    #python_requires='>=3.6',
    install_requires=['numpy'],
)
