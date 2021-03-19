#ifndef __Navigation_heap_h__
#define __Navigation_heap_h__

#include <algorithm>
#include <vector>

template <typename K>
class QueueMap {
public:
    QueueMap(bool (*fct)(K, K))
    {
        this->items = new std::vector<K>();
        this->fct = fct;
    }

    ~QueueMap()
    {
        delete this->items;
    }

    void Push(K key)
    {
        this->items->push_back(key);
        std::push_heap(this->items->begin(), this->items->end(), this->fct);
    }
    K Pop()
    {
        K value = this->items->front();
        std::pop_heap(this->items->begin(), this->items->end(), this->fct);
        this->items->pop_back();
        return value;
    }
    bool Has(K key)
    {
        return (std::find(this->items->begin(), this->items->end(), key) != this->items->end());
    }
    void Update(K key)
    {
        this->items->erase(std::find(this->items->begin(), this->items->end(), key));
        std::make_heap(this->items->begin(), this->items->end(), this->fct);
        Push(key);
    }
    bool Empty()
    {
        return this->items->empty();
    }

    void Destroy()
    {
        this->items->clear();
        delete this->items;
    }

public:
    std::vector<K>* items;
    bool (*fct)(K, K);
};

#endif