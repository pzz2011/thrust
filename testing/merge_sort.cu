#include <thrusttest/unittest.h>
#include <thrust/sorting/merge_sort.h>
#include <thrust/functional.h>

template <typename T>
struct less_div_10
{
  __host__ __device__ bool operator()(const T &lhs, const T &rhs) const {return ((int) lhs) / 10 < ((int) rhs) / 10;}
};



template <class Vector>
void InitializeSimpleKeySortTest(Vector& unsorted_keys, Vector& sorted_keys)
{
    unsorted_keys.resize(7);
    unsorted_keys[0] = 1; 
    unsorted_keys[1] = 3; 
    unsorted_keys[2] = 6;
    unsorted_keys[3] = 5;
    unsorted_keys[4] = 2;
    unsorted_keys[5] = 0;
    unsorted_keys[6] = 4;

    sorted_keys.resize(7); 
    sorted_keys[0] = 0; 
    sorted_keys[1] = 1; 
    sorted_keys[2] = 2;
    sorted_keys[3] = 3;
    sorted_keys[4] = 4;
    sorted_keys[5] = 5;
    sorted_keys[6] = 6;
}

template <class Vector>
void InitializeSimpleKeyValueSortTest(Vector& unsorted_keys, Vector& unsorted_values,
                                      Vector& sorted_keys,   Vector& sorted_values)
{
    unsorted_keys.resize(7);   
    unsorted_values.resize(7);   
    unsorted_keys[0] = 1;  unsorted_values[0] = 0;
    unsorted_keys[1] = 3;  unsorted_values[1] = 1;
    unsorted_keys[2] = 6;  unsorted_values[2] = 2;
    unsorted_keys[3] = 5;  unsorted_values[3] = 3;
    unsorted_keys[4] = 2;  unsorted_values[4] = 4;
    unsorted_keys[5] = 0;  unsorted_values[5] = 5;
    unsorted_keys[6] = 4;  unsorted_values[6] = 6;
    
    sorted_keys.resize(7);
    sorted_values.resize(7);
    sorted_keys[0] = 0;  sorted_values[1] = 0;  
    sorted_keys[1] = 1;  sorted_values[3] = 1;  
    sorted_keys[2] = 2;  sorted_values[6] = 2;
    sorted_keys[3] = 3;  sorted_values[5] = 3;
    sorted_keys[4] = 4;  sorted_values[2] = 4;
    sorted_keys[5] = 5;  sorted_values[0] = 5;
    sorted_keys[6] = 6;  sorted_values[4] = 6;
}

template <class Vector>
void InitializeSimpleStableKeySortTest(Vector& unsorted_keys, Vector& sorted_keys)
{
    unsorted_keys.resize(9);   
    unsorted_keys[0] = 25; 
    unsorted_keys[1] = 14; 
    unsorted_keys[2] = 35; 
    unsorted_keys[3] = 16; 
    unsorted_keys[4] = 26; 
    unsorted_keys[5] = 34; 
    unsorted_keys[6] = 36; 
    unsorted_keys[7] = 24; 
    unsorted_keys[8] = 15; 
    
    sorted_keys.resize(9);
    sorted_keys[0] = 14; 
    sorted_keys[1] = 16; 
    sorted_keys[2] = 15; 
    sorted_keys[3] = 25; 
    sorted_keys[4] = 26; 
    sorted_keys[5] = 24; 
    sorted_keys[6] = 35; 
    sorted_keys[7] = 34; 
    sorted_keys[8] = 36; 
}


template <class Vector>
void TestMergeSortKeySimple(void)
{
    typedef typename Vector::value_type T;

    Vector unsorted_keys;
    Vector   sorted_keys;

    InitializeSimpleKeySortTest(unsorted_keys, sorted_keys);

    thrust::sorting::merge_sort(unsorted_keys.begin(), unsorted_keys.end());

    ASSERT_EQUAL(unsorted_keys, sorted_keys);
}
DECLARE_VECTOR_UNITTEST(TestMergeSortKeySimple);


template <class Vector>
void TestMergeSortKeyValueSimple(void)
{
    Vector unsorted_keys, unsorted_values;
    Vector   sorted_keys,   sorted_values;

    InitializeSimpleKeyValueSortTest(unsorted_keys, unsorted_values, sorted_keys, sorted_values);

    thrust::sorting::merge_sort_by_key(unsorted_keys.begin(), unsorted_keys.end(), unsorted_values.begin());

    ASSERT_EQUAL(unsorted_keys,   sorted_keys);
    ASSERT_EQUAL(unsorted_values, sorted_values);
}
DECLARE_VECTOR_UNITTEST(TestMergeSortKeyValueSimple);


template <class Vector>
void TestMergeSortStableKeySimple(void)
{
    typedef typename Vector::value_type T;

    Vector unsorted_keys;
    Vector   sorted_keys;

    InitializeSimpleStableKeySortTest(unsorted_keys, sorted_keys);

    thrust::sorting::merge_sort(unsorted_keys.begin(), unsorted_keys.end(), less_div_10<T>());

    ASSERT_EQUAL(unsorted_keys,   sorted_keys);
}
DECLARE_VECTOR_UNITTEST(TestMergeSortStableKeySimple);


template <typename T>
void TestMergeSortAscendingKey(const size_t n)
{
    thrust::host_vector<T>   h_data = thrusttest::random_integers<T>(n);
    thrust::device_vector<T> d_data = h_data;

    thrust::sorting::merge_sort(h_data.begin(), h_data.end(), thrust::less<T>());
    thrust::sorting::merge_sort(d_data.begin(), d_data.end(), thrust::less<T>());

    ASSERT_EQUAL(h_data, d_data);
}
DECLARE_VARIABLE_UNITTEST(TestMergeSortAscendingKey);


void TestMergeSortDescendingKey(void)
{
    const size_t n = 10027;

    thrust::host_vector<int>   h_data = thrusttest::random_integers<int>(n);
    thrust::device_vector<int> d_data = h_data;

    thrust::sorting::merge_sort(h_data.begin(), h_data.end(), thrust::greater<int>());
    thrust::sorting::merge_sort(d_data.begin(), d_data.end(), thrust::greater<int>());

    ASSERT_EQUAL(h_data, d_data);
}
DECLARE_UNITTEST(TestMergeSortDescendingKey);


template <typename T>
void TestMergeSortAscendingKeyValue(const size_t n)
{
    thrust::host_vector<T>   h_keys = thrusttest::random_integers<T>(n);
    thrust::device_vector<T> d_keys = h_keys;
    
    thrust::host_vector<T>   h_values = thrusttest::random_integers<T>(n);
    thrust::device_vector<T> d_values = h_values;

    thrust::sorting::merge_sort_by_key(h_keys.begin(), h_keys.end(), h_values.begin(), thrust::less<T>());
    thrust::sorting::merge_sort_by_key(d_keys.begin(), d_keys.end(), d_values.begin(), thrust::less<T>());

    ASSERT_EQUAL(h_keys,   d_keys);
    ASSERT_EQUAL(h_values, d_values);
}
DECLARE_VARIABLE_UNITTEST(TestMergeSortAscendingKeyValue);


void TestMergeSortDescendingKeyValue(void)
{
    const size_t n = 10027;

    thrust::host_vector<int>   h_keys = thrusttest::random_integers<int>(n);
    thrust::device_vector<int> d_keys = h_keys;
    
    thrust::host_vector<int>   h_values = thrusttest::random_integers<int>(n);
    thrust::device_vector<int> d_values = h_values;

    thrust::sorting::merge_sort_by_key(h_keys.begin(), h_keys.end(), h_values.begin(), thrust::greater<int>());
    thrust::sorting::merge_sort_by_key(d_keys.begin(), d_keys.end(), d_values.begin(), thrust::greater<int>());

    ASSERT_EQUAL(h_keys,   d_keys);
    ASSERT_EQUAL(h_values, d_values);
}
DECLARE_UNITTEST(TestMergeSortDescendingKeyValue);


template <class Vector>
void TestMergeSortUnalignedSimple(void)
{
    typedef typename Vector::value_type T;

    Vector unsorted_keys;
    Vector   sorted_keys;

    InitializeSimpleKeySortTest(unsorted_keys, sorted_keys);
    
    for(int offset = 1; offset < 16; offset++){
        size_t n = unsorted_keys.size() + offset;

        Vector unaligned_unsorted_keys(n, 0);
        Vector   unaligned_sorted_keys(n, 0);
        
        thrust::copy(unsorted_keys.begin(), unsorted_keys.end(), unaligned_unsorted_keys.begin() + offset);
        thrust::copy(  sorted_keys.begin(),   sorted_keys.end(),   unaligned_sorted_keys.begin() + offset);
   
        thrust::sorting::merge_sort(unaligned_unsorted_keys.begin() + offset, unaligned_unsorted_keys.end());

        ASSERT_EQUAL(unaligned_unsorted_keys, unaligned_sorted_keys);
    }
}
DECLARE_VECTOR_UNITTEST(TestMergeSortUnalignedSimple);


template <class Vector>
void TestMergeSortByKeyUnalignedSimple(void)
{
    typedef typename Vector::value_type T;

    Vector unsorted_keys, unsorted_values;
    Vector   sorted_keys,   sorted_values;

    InitializeSimpleKeyValueSortTest(unsorted_keys, unsorted_values, sorted_keys, sorted_values);

    for(int offset = 1; offset < 16; offset++){
        size_t n = unsorted_keys.size() + offset;

        Vector   unaligned_unsorted_keys(n, 0);
        Vector     unaligned_sorted_keys(n, 0);
        Vector unaligned_unsorted_values(n, 0);
        Vector   unaligned_sorted_values(n, 0);
        
        thrust::copy(  unsorted_keys.begin(),   unsorted_keys.end(),   unaligned_unsorted_keys.begin() + offset);
        thrust::copy(    sorted_keys.begin(),     sorted_keys.end(),     unaligned_sorted_keys.begin() + offset);
        thrust::copy(unsorted_values.begin(), unsorted_values.end(), unaligned_unsorted_values.begin() + offset);
        thrust::copy(  sorted_values.begin(),   sorted_values.end(),   unaligned_sorted_values.begin() + offset);
   
        thrust::sorting::merge_sort_by_key(unaligned_unsorted_keys.begin() + offset, unaligned_unsorted_keys.end(), unaligned_unsorted_values.begin() + offset);

        ASSERT_EQUAL(  unaligned_unsorted_keys,   unaligned_sorted_keys);
        ASSERT_EQUAL(unaligned_unsorted_values, unaligned_sorted_values);
    }
}
DECLARE_VECTOR_UNITTEST(TestMergeSortByKeyUnalignedSimple);


