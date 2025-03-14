tests="${1:-./tests}"

nvim-test --headless \
  -c "PlenaryBustedDirectory $tests { init = './scripts/minimal_init.lua', nvim_cmd = '$(which nvim-test)' }"
