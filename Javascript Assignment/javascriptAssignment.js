// 1) 1. Write a function called findMin that accepts a variable number of arguments and returns the smallest argument.
//    Make sure to do this using the rest and spread operator.

function findMin(...args) {
    if (args.length === 0) {
      return undefined;  
    }
    return Math.min(...args);
  } 
  

  // 2) Create a class Animal with a constructor setting the name property. Then, create 
  // a subclass dog that extendsAnimal and adds a bark method which prints dog name.(use prototype-based inheritance)
  // Define the Animal constructor (Animal class)
  function Animal(name) {
    this.name = name;
  }
  
  // Define the Dog constructor (Dog class)
  function Dog(name) {
    // Call the Animal constructor to set the name property
    Animal.call(this, name);
  }
  
  // Set up prototype-based inheritance: Dog inherits from Animal
  Dog.prototype = Object.create(Animal.prototype);
  Dog.prototype.constructor = Dog; // Important: Reset constructor
  
  // Add the bark method to the Dog prototype
  Dog.prototype.bark = function() {
    console.log(this.name + " says Woof!");
  };
  


  // 3) Write a function multiplyByEight, Note: Use Closures, don't return 8*x directly.
  
  function multiplyByEight(){
      const multiplier = 8;
      return function(num){
          return num*multiplier;
      }
  }


  // 4) Create a function waitAndReturn that returns a Promise which resolves with the 
  // string "Resolved" after 5 seconds. Then, use async/await to call this function
  //   and log the result.
  

  //--> a promise is a way to handle async calls
  function waitAndReturn(){
      return new Promise((resolve)=>{
          setTimeout(() => { 
                  resolve("Resolved");
             }, 5000);
      });
  }
  
  //-> the wait keyword is used to wait for a promise to resolve
  async function print(){
      str = await waitAndReturn();
  
      console.log(str);
  }
  

  // 5) Create a function to mutate an array with filter out values specified. (Hint : Use filter(), includes(), push())
  //    const filteredArray = (originalArray, removeValuesArray) => {//}

  const filteredArray = (currentArray, removeElementArr)=>{
    return currentArray.filter((element)=> !removeElementArr.includes(element));
  }
  

  // test this above wala

  const result = filteredArray([1,2,3,4,5,6,7,8], [4,5,6]);
  
  console.log(result);

