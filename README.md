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
- A post-extraction heuristic was added specifically to cater for this test case.
	- The heuristic first determines if most of the nutrient observations have a smaller `value2`
	- If this is the case, each of the invalid nutrient observations (ie. having a smaller `value1`), are corrected by:
		- Determining if we have a 2 digit `Value` for `value2`
		- If so, placing a decimal place between them to form a smaller number
		- Checking if this number now satisfies the condition of `value2 < value1`
		- If so, assigning this corrected `Value` to the observation

#### Future Work
- A note-worthy and arbitrary assumption we're making here is that smaller column always holds the correctly recognized `Value`.
	- However, what if it were the smaller column that needed to be increased instead?
		- **Keep in mind that this is less probable than the assumption we're making—as a misread is more likely to result in the decimal place being removed as opposed to additional incorrect digits being recognized.**
	- We may want to fix this at a later point in the future if we do encounter cases where the larger column is correctly recognized one, by doing something like:
		- Using the macro and energy observations to determine which column is in fact correct (by seeing which one is closest to being equal once plugged into the equation)
			- This would however, have the sidefect of us only being able to correct macro and energy observations, unless we discover a heuristic that can determine which column of a micronutrient is valid.