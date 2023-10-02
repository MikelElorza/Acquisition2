To run the python demo, consider, that python interpreters may come
in 32-bit and 64-bit technology as well. Copy the appropriate PDLM-
API DLL into this directory and rename it to "pdlm_lib.dll". You'll
find the respective flavoured versions in the directories side by
side with the "\Demos" main directory.

Notice: Compared to the other programming languages, the C# and the
Python demos are not designed as "self-contained" environments (a.k.a.
library wrappers), they have only those constants and types declared,
that are needed for a run of the demo applications. In your own appli-
cations on the other hand, you might need more and other API-constants.
Please, refer to the files named starting with "PDLMUser_..." in the
directory "Demos\MSVCPP\Common_Files" or "Demos\Delphi" to learn more
about other provided constants, types or functions.