module sqld.util;

import std.algorithm,
       std.string;

/**
 * Reads boolean from string.
 * 
 * Case-insensitive, returns true if string value is one of:
 *  1, yes, true
 */
bool strToBool(string s)
{
    return ["1", "yes", "true"].countUntil(s.toLower()) != -1;
}