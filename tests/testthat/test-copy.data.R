context('Copy data to clipboard')

################################################################################
# start of the DO NOT CHANGE section !!! - unless you know what you are doing
# position of the code in this section is referenced in the test methods.
# changes here might break tests!

# dummy method
.foobar <- function( .x_y_z, a )
{
a <- F # not indented on purpose

    if (missing(.x_y_z)) {
        print('Please set a list .x_y_z.')
    } else {
        print(.x_y_z$pi)
    }

    a
}
# end of the DO NOT CHANGE section !!!
################################################################################

test_that('get.tsv.atomic',
{
    expect_identical(get.tsv.atomic(), '')

    vec <- 1:3
    expect_identical(get.tsv.atomic(list(value=vec)), '1\t2\t3')

    names(vec) <- letters[1:3]
    expect_identical(get.tsv.atomic(list(value=vec)), 'a\tb\tc\n1\t2\t3')

    vec <- c(vec, 4)
    expect_identical(get.tsv.atomic(list(value=vec)), 'a\tb\tc\t\n1\t2\t3\t4')

    vec <- c(vec, NA)
    expect_identical(get.tsv.atomic(list(value=vec)), 'a\tb\tc\t\t\n1\t2\t3\t4\tNA')
})

test_that('get.tsv.matrix',
{
    expect_identical(get.tsv.matrix(), '')

    mat <- matrix(1:12, nrow=3, byrow=T)
    expect_identical(get.tsv.matrix(list(value=mat)), '1\t2\t3\t4\n5\t6\t7\t8\n9\t10\t11\t12')

    dimnames(mat) <- list(letters[1:3])
    expect_identical(get.tsv.matrix(list(value=mat)), 'a\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(let=letters[1:3])
    expect_identical(get.tsv.matrix(list(value=mat)), 'a\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(NULL, month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), 'Jan\tFeb\tMar\tApr\n1\t2\t3\t4\n5\t6\t7\t8\n9\t10\t11\t12')

    dimnames(mat) <- list(NULL, months=month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), 'Jan\tFeb\tMar\tApr\n1\t2\t3\t4\n5\t6\t7\t8\n9\t10\t11\t12')

    dimnames(mat) <- list(letters[1:3], month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), '\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(let=letters[1:3], month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), 'let\\\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(letters[1:3], months=month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), '\\months\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(let=letters[1:3], months=month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), 'let\\months\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')
})


test_that('adjust.selection',
{
    skip_if_not(rstudioapi::isAvailable(REQUIRED.RSTUDIO.VERSION), 'RStudio is not available!')

    #' @title Generate tests
    place.in.word <- function(expected, info)
    {
        # first char
        rstudioapi::setCursorPosition(rstudioapi::document_position(expected$row, expected$start))
        expect_identical( adjust.selection(), expected
                        , paste0(info, ': cursor at the first character'))

        # last char
        rstudioapi::setCursorPosition(rstudioapi::document_position(expected$row, expected$end))
        expect_identical( adjust.selection(), expected
                        , paste0(info, ': cursor after the last character'))

        # in the middle
        if (nchar(expected$text) > 1) {
            rstudioapi::setCursorPosition(rstudioapi::document_position(expected$row, expected$start + 1))
            expect_identical( adjust.selection(), expected
                            , paste0(info, ': cursor in the middle of the word'))
        }

        # subselection
        if (nchar(expected$text) > 2) {
            rstudioapi::setSelectionRanges(
                rstudioapi::document_range(
                      rstudioapi::document_position(expected$row, expected$start + 1)
                    , rstudioapi::document_position(expected$row, expected$end   - 1)))
            expect_identical( adjust.selection(), expected
                            , paste0(info, ': selection inside the word'))
        }

        # selection from the start of the word till the end of line
        rstudioapi::setSelectionRanges(
            rstudioapi::document_range(
                  rstudioapi::document_position(expected$row, expected$start)
                , rstudioapi::document_position(expected$row, Inf)))
        expect_identical( adjust.selection(), expected
                        , paste0(info, ': selection from the start of the word till the end of line'))

        # selection from the start of the word till the end of file
        rstudioapi::setSelectionRanges(
            rstudioapi::document_range(
                  rstudioapi::document_position(expected$row, expected$start)
                , rstudioapi::document_position(Inf, Inf)))
        expect_identical( adjust.selection(), expected
                        , paste0(info, ': selection from the start of the word till the end of file'))

        if (nchar(expected$text) > 1) {
            # selection from middle of the word till the end of line
            rstudioapi::setSelectionRanges(
                rstudioapi::document_range(
                      rstudioapi::document_position(expected$row, expected$start + 1)
                    , rstudioapi::document_position(expected$row, Inf)))
            expect_identical( adjust.selection(), expected
                            , paste0(info, ': selection from the middle of the word till the end of line'))

            # selection from the middle of the word till the end of file
            rstudioapi::setSelectionRanges(
                rstudioapi::document_range(
                      rstudioapi::document_position(expected$row, expected$start + 1)
                    , rstudioapi::document_position(Inf, Inf)))
            expect_identical( adjust.selection(), expected
                            , paste0(info, ': selection from the middle of the word till the end of file'))
        }

        # selection from the end of the word till the end of line
        rstudioapi::setSelectionRanges(
            rstudioapi::document_range(
                  rstudioapi::document_position(expected$row, expected$end)
                , rstudioapi::document_position(expected$row, Inf)))
        expect_identical( adjust.selection(), expected
                        , paste0(info, ': selection from the end of the word till the end of line'))

        # selection from the end of the word till the end of file
        rstudioapi::setSelectionRanges(
            rstudioapi::document_range(
                  rstudioapi::document_position(expected$row, expected$end)
                , rstudioapi::document_position(Inf, Inf)))
        expect_identical( adjust.selection(), expected
                        , paste0(info, ': selection from the end of the word till the end of file'))
    }

    # value is a line number of the line: '# dummy method'
    test.first.line <- 8

    # long word at the beginning of the line
    place.in.word(list(row=test.first.line + 1, start=1, end=8, text='.foobar'), 'long word at the beginning of the line')

    # long word in the middle of the line
    place.in.word(list(row=test.first.line + 1, start=12, end=20, text='function'), 'long word in the middle of the line')

    # long word at the end of the line
    place.in.word(list(row=test.first.line, start=9, end=15, text='method'), 'long word at the end of the line')

    # short word at the beginning of the line
    place.in.word(list(row=test.first.line + 3, start=1, end=2, text='a'), 'short word at the beginning of the line')

    # short word in the middle of the line
    place.in.word(list(row=test.first.line + 6, start=27, end=28, text='a'), 'short word in the middle of the line')

    # short word at the end of the line
    place.in.word(list(row=test.first.line + 11, start=5, end=6, text='a'), 'short word at the end of the line')

    # some non-automated examples
    # multiline selection before the short word
    expected <- list(row=test.first.line + 3, start=1, end=2, text='a')
    rstudioapi::setSelectionRanges(
        rstudioapi::document_range(
              rstudioapi::document_position(test.first.line + 1, 32)
            , rstudioapi::document_position(expected$row, expected$start)))
    expect_identical( adjust.selection(), expected
                    , 'multiline selection before the short word')

    # multiline selection before the longer word
    expected <- list(row=test.first.line + 5, start=5, end=7, text='if')
    rstudioapi::setSelectionRanges(
        rstudioapi::document_range(
              rstudioapi::document_position(test.first.line + 4, 1)
            , rstudioapi::document_position(expected$row, expected$start)))
    expect_identical( adjust.selection(), expected
                    , 'multiline selection before the short word')
})