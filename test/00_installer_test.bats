#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'


@test "install dependencies" {
  run rm /usr/local/bin/docker-compose
  run bash new_install.sh
  assert_success
}

@test "check docker" {
  run docker -v
  assert_success
}

@test "check docker-compose" {
  run docker-compose -v
  assert_success
}

@test "check php" {
  run php -v
  assert_success
}

@test "check php curl" {
  run php -m | grep curl
  assert_success
}

@test "check php sqlite3" {
  run php -m | grep sqlite3
  assert_success
}
