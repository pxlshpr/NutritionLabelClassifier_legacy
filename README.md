# Nutrition Facts Classifier
A Swift framework that classifies Nutrition Label features from [recognized text observations](https://developer.apple.com/documentation/vision/vnrecognizedtextobservation) extracted using the [Vision framework](https://developer.apple.com/documentation/vision).

## Releases

### 0.0.117
#### Failing Test
- Test Case: C132B648-8974-457A-8EE6-824688D901EA
- Attribute: `.protein.value2`
- Expected: `4.3g`
- Observation: `43g`

#### Possible Heuristic
- Add a heuristic at the end of getting all the nutrients that
  - First determines whether `value1` or `value2` is larger (by checking what the majority of the rows return)
  - Goes through each nutrient row and make sure `value2` is `<` or `>` `value1` depending on what was determined
  - If it fails this check
    - First if we have a 2-digit `Int` `Value` for `value2` or `value1`
		- See if placing a decimal place in between the numbers satisfies the comparison condition.
		- If it does, correct the value to this
	- As a fallback
		- Get the average ratio between all the valid rows (ie. that satisfy the comparison condition)
		- Now apply this ratio to the incorrect observations to correct the values.

#### Changes
- 