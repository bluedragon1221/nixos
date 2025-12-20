{
  age.secrets = {
    "collin@mercury-passwd".file = ./${"collin-mercury-passwd.age"};
    "collin@jupiter-passwd".file = ./${"./collin-mercury-passwd.age"};
  };
}
