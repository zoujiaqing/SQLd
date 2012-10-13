module sqld.util;

import std.algorithm;

bool strToBool(string s)
{
    return ["1", "y", "yes", "true", "t"].countUntil(s) != -1;
}