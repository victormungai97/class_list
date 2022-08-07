// here, all mutations will reside
// a mutation is the GraphQL equivalent of HTTP POST
// '\\' escapes the '$'
/// Creating mutations involves wrapping mutation in a multiline string

/// Register student by passing in student's details

String registerStudent = """
mutation NewStudentMutation (
    \$regno: String!, 
    \$name: String!, 
    \$email: String!, 
    \$year: String!, 
    \$department: String!,
    \$zipFile: String!
	) {
  newStudent(input: {
    	regNo: \$regno, 
    	name: \$name, 
    	email: \$email, 
    	year: \$year, 
    	department: \$department,
      zipFile: \$zipFile
  	}
  ) {
    status
    message
    studentNode {
      name
      regNum
    }
  }
}

"""
    .replaceAll('\n', ' ');

/// Log student in by sending reg number

String staffLogin = """
mutation StaffLoginMutation (
  \$staffID: String!,
  \$password: String!
)
{
  staffLogin(input: {
    staffId: \$staffID,
    password: \$password
  })
  {
    message
    status
    accessToken
    refreshToken
    staffNode{
      user
    }
  }
}
"""
    .replaceAll('\n', ' ');

/// Reset staff password by sending ID

String resetStaffPassword = """
mutation ResetStaffPasswordMutation(\$staffId: String!) {
  resetStaffPassword(input: {staffId: \$staffId}) {
    message
    status
    staffNode {
      id
    }
  }
}
"""
    .replaceAll('\n', ' ');

/// Log student in by sending reg number

String studentLogin = """
mutation StudentLoginMutation (
  \$regno: String!
)
{
  studentLogin(input: {regNo: \$regno}){
    message
    status
    accessToken
    studentNode {
      id
    }
  }
}
"""
    .replaceAll('\n', ' ');
