#define TOSTR(x) #x+" "   // macro for displaying an object name

#property library List
#property copyright "Copyright © 2024 Manuel Leon Rivas (mleonrivas@gmail.com)"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

template <typename T>
class List {
   private:
      T* elements[];
   public:
      // default constructor
      List() { }

      int size() {
         return ArraySize(elements);
      }

      void add(T* element) {
         int size = this.size();
         ArrayResize(elements, size+1, 100);
         elements[size] = element;
      }

      T* get(int index) {
         return elements[index];
      }

      T* getLast() {
         int index = this.size()-1;
         return elements[index];
      }

      T* remove(int index) {
         int size = this.size();
         if (index < 0 || index >= size) {
            return NULL;
         }
         // move element to the last
         T* elem = elements[index];
         for (int i=index+1; i < size; i++) {
            elements[i-1] = elements[i];
         }
         elements[size-1] = NULL;
         ArrayResize(elements, size-1, 100);
         return elem;
      }

      void release() {
         for (int i=0; i<this.size(); i++) {
            delete elements[i];
            elements[i] = NULL;
         }
      }
};

