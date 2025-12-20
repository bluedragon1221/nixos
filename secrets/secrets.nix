let
  user_mercury = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvxtKW0rmRBi8J67gLrLv8Zv338AcmZ3P20DePiUfnX";
  user_jupiter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGK8U+m6/9g7/AduxQcawJrA2V3lSEUrF7j/oJwPow3q";

  system_mercury = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIQtMAgPdWwrOzlZT/lEIRQZ+ajhafG9AEJCrF2/bsmN";
  system_jupiter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTSXbRaBDe09gkREhYrRVis+CtxpHOcDoIRdUAAO/Js";
in {
  "collin-mercury-passwd.age" = {
    publicKeys = [user_mercury system_mercury];
    armor = true;
  };
  "collin-jupiter-passwd.age" = {
    publicKeys = [user_jupiter system_jupiter];
    armor = true;
  };
}
