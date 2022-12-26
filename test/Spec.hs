import Test.HUnit
import Lib

testCombinePath = TestCase $ assertEqual "combine path" "ftgen/fibo" (combinePath "ftgen" "fibo")

main :: IO Counts 
main = 
    runTestTT $ TestList [
        testCombinePath
    ] 
