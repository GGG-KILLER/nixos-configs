{ lib, ... }:
let
  base = 10;
  getSeq = num: lib.fixedWidthNumber 4 (base + num);
in
{
  services.opensnitch.rules."${getSeq 1}-block-regex" = {
    name = "${getSeq 1}-block-regex";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    precedence = true;
    action = "reject";
    duration = "always";
    operator = {
      type = "list";
      operand = "list";
      list = [
        {
          type = "lists";
          operand = "lists.domains";
          data = builtins.filterSource (
            path: type: type == "directory" || !lib.hasSuffix ".etag" path
          ) ./reject/hosts;
        }
      ];
    };
  };

  services.opensnitch.rules."${getSeq 2}-block-hosts" = {
    name = "${getSeq 2}-block-hosts";
    created = "1970-01-01T00:00:00Z";
    enabled = true;
    precedence = true;
    action = "reject";
    duration = "always";
    operator = {
      type = "list";
      operand = "list";
      list = [
        {
          type = "lists";
          operand = "lists.domains_regexp";
          data = builtins.filterSource (
            path: type: type == "directory" || !lib.hasSuffix ".etag" path
          ) ./reject/regex;
        }
      ];
    };
  };
}
