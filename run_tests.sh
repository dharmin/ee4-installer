#!/bin/bash

global_setup() {
  [[ ! -f "${BATS_PARENT_TMPNAME}.skip" ]] || skip "$SKIPPED_TEST_ERR_MSG"
}

global_teardown() {
  [[ -n "$BATS_TEST_COMPLETED" ]] || touch "${BATS_PARENT_TMPNAME}.skip"
}