extends GutTest

func test_are_tests_running():
	assert_eq(Utils.are_tests_running(), true, "should return true when tests are running")