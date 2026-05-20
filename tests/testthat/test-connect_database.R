test_that("connect_database returns SQLiteConnection", {
    skip_if_offline()
    
    conn <- suppressMessages(connect_database())
    expect_s4_class(conn, "SQLiteConnection")
    DBI::dbDisconnect(conn)
    
    conn_sp <- suppressMessages(connect_database(species_id = 99))
    expect_s4_class(conn_sp, "SQLiteConnection")
    DBI::dbDisconnect(conn_sp)
})

test_that("connect_database invalid species error", {
    skip_if_offline()
    
    expect_error(connect_database(species_id = 999999))
})
